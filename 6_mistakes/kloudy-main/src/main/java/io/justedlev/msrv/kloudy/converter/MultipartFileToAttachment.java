package io.justedlev.msrv.kloudy.converter;

import io.justedlev.msrv.kloudy.repository.entity.FileMetadata;
import org.springframework.core.convert.converter.Converter;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.util.Objects;

@Component
public class MultipartFileToAttachment implements Converter<MultipartFile, FileMetadata> {
    @Nullable
    @Override
    public FileMetadata convert(@Nullable MultipartFile source) {

        if (Objects.isNull(source)) {
            return null;
        }

        return FileMetadata.builder()
                .filename(source.getOriginalFilename())
                .extension(StringUtils.getFilenameExtension(source.getOriginalFilename()))
                .type(source.getContentType())
                .length(source.getSize())
                .build();
    }
}
