package io.justedlev.msrv.kloudy.repository.entity;

import io.justedlev.sb3c.DefaultAuditable;
import io.justedlev.sb3c.DefaultPersistable;
import io.justedlev.sb3c.DefaultVersionable;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.DynamicUpdate;
import org.hibernate.envers.AuditOverride;
import org.hibernate.envers.Audited;

import java.io.Serializable;
import java.util.UUID;

@Getter
@Setter
@With
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@Audited
@AuditOverride(forClass = DefaultVersionable.class)
@AuditOverride(forClass = DefaultAuditable.class)
@AuditOverride(forClass = DefaultPersistable.class)
@Entity
@DynamicUpdate
@Table(name = "file_metadata")
@ToString
public class FileMetadata extends DefaultVersionable<UUID> implements Serializable {

    @NotBlank
    @Column(name = "filename", nullable = false)
    private String filename;

    @Column(name = "extension")
    private String extension;

    @NotBlank
    @Column(name = "type", nullable = false)
    private String type;

    @Min(1)
    @Column(name = "length", nullable = false)
    private Long length;

}
