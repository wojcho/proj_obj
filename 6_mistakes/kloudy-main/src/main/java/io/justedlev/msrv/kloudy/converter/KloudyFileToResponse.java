package io.justedlev.msrv.kloudy.converter;

import io.justedlev.msrv.kloudy.model.KloudyFileResponse;
import io.justedlev.msrv.kloudy.repository.entity.FileMetadata;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.core.convert.converter.Converter;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class KloudyFileToResponse implements Converter<FileMetadata, KloudyFileResponse> {
    private final ModelMapper mapper;

    @Nullable
    @Override
    public KloudyFileResponse convert(@Nullable FileMetadata source) {
        return mapper.map(source, KloudyFileResponse.class);
    }
}
