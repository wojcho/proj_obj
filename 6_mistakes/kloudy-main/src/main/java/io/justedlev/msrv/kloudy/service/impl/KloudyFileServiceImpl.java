package io.justedlev.msrv.kloudy.service.impl;

import io.justedlev.msrv.kloudy.configuration.properties.KloudyProperties;
import io.justedlev.msrv.kloudy.converter.KloudyFileToResponse;
import io.justedlev.msrv.kloudy.converter.MultipartFileToAttachment;
import io.justedlev.msrv.kloudy.model.DownloadResponse;
import io.justedlev.msrv.kloudy.model.KloudyFileFilterParams;
import io.justedlev.msrv.kloudy.model.KloudyFileResponse;
import io.justedlev.msrv.kloudy.repository.FileMetadataRepository;
import io.justedlev.msrv.kloudy.repository.entity.FileMetadata;
import io.justedlev.msrv.kloudy.repository.specs.FileMetadataSpecifications;
import io.justedlev.msrv.kloudy.service.KloudyFileService;
import io.vavr.CheckedFunction0;
import io.vavr.control.Try;
import jakarta.persistence.EntityNotFoundException;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.FileSystemResource;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Supplier;

@Slf4j
@Service
@RequiredArgsConstructor
public class KloudyFileServiceImpl implements KloudyFileService {
    private final FileMetadataRepository fileMetadataRepository;
    private final KloudyProperties properties;
    private final MultipartFileToAttachment multipartFileToAttachment;
    private final KloudyFileToResponse kloudyFileToResponse;

    @SneakyThrows
    @Transactional
    @Override
    public KloudyFileResponse upload(@NonNull MultipartFile file) {
        var entity = Optional.of(file)
                .map(multipartFileToAttachment::convert)
                .map(fileMetadataRepository::save)
                .orElseThrow();
        var copyLocation = properties.getRoot().resolve(entity.id().toString());
        Files.copy(file.getInputStream(), copyLocation, StandardCopyOption.ATOMIC_MOVE);

        return kloudyFileToResponse.convert(entity);
    }

    @Override
    public KloudyFileResponse getOne(UUID id) {
        return fileMetadataRepository.findById(id)
                .map(kloudyFileToResponse::convert)
                .orElseThrow(notFound(id));
    }

    @Override
    public PagedModel<KloudyFileResponse> findAll(KloudyFileFilterParams params, Pageable pageable) {
        var spec = FileMetadataSpecifications.freeSearch(params.getQ());
        var page = fileMetadataRepository.findAll(spec, pageable);
        var res = page.map(kloudyFileToResponse::convert);

        return new PagedModel<>(res);
    }

    @Transactional
    @Override
    public void delete(UUID id) {
        Try.of(CheckedFunction0.constant(id))
                .map(fileMetadataRepository::findById)
                .mapTry(opt -> opt.orElseThrow(notFound(id)))
                .map(FileMetadata::id)
                .map(UUID::toString)
                .map(properties.getRoot()::resolve)
                .filter(Files::exists)
                .andThenTry(Files::delete)
                .andFinallyTry(() -> fileMetadataRepository.deleteById(id))
                .onFailure(ex -> log.error("Failed delete file", ex));
    }

    @Override
    public DownloadResponse download(UUID id) {
        var entity = fileMetadataRepository.findById(id)
                .orElseThrow(notFound(id));
        var path = properties.getRoot().resolve(entity.id().toString());

        return DownloadResponse.builder()
                .filename(entity.getFilename())
                .extension(entity.getExtension())
                .resource(new FileSystemResource(path))
                .length(entity.getLength())
                .contentType(MediaType.parseMediaType(entity.getType()))
                .build();
    }

    private Supplier<RuntimeException> notFound(UUID id) {
        return () -> new EntityNotFoundException("Kloudy file not found: " + id);
    }
}
