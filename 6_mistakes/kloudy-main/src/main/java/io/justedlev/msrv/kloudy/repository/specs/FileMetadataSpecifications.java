package io.justedlev.msrv.kloudy.repository.specs;

import io.justedlev.msrv.kloudy.repository.entity.FileMetadata;
import io.justedlev.msrv.kloudy.repository.entity.FileMetadata_;
import lombok.experimental.UtilityClass;
import org.apache.commons.lang3.StringUtils;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

import java.util.Optional;

@UtilityClass
public class FileMetadataSpecifications {
    public static final Specification<FileMetadata> EMPTY = Specification.where(null);

    @NonNull
    public static Specification<FileMetadata> freeSearch(@Nullable String text) {

        if (StringUtils.isBlank(text)) {
            return EMPTY;
        }

        return (root, cq, cb) -> Optional.of(text)
                .filter(StringUtils::isNotBlank)
                .map(String::strip)
                .map(cb::literal)
                .map(exp -> cb.concat("%", exp))
                .map(exp -> cb.concat(exp, "%"))
                .map(exp -> cb.or(
                        cb.like(root.get(FileMetadata_.filename), exp),
                        cb.like(root.get(FileMetadata_.extension), exp),
                        cb.like(root.get(FileMetadata_.type), exp)
                ))
                .orElse(null);
    }

}
