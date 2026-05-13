package io.justedlev.msrv.kloudy.service;

import io.justedlev.msrv.kloudy.model.DownloadResponse;
import io.justedlev.msrv.kloudy.model.KloudyFileFilterParams;
import io.justedlev.msrv.kloudy.model.KloudyFileResponse;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

public interface KloudyFileService {

    KloudyFileResponse upload(MultipartFile file);

    KloudyFileResponse getOne(UUID id);

    PagedModel<KloudyFileResponse> findAll(KloudyFileFilterParams params, Pageable pageable);

    void delete(UUID id);

    DownloadResponse download(UUID id);

}
