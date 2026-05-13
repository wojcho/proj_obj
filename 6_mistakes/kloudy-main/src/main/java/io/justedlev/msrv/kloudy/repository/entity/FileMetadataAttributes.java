package io.justedlev.msrv.kloudy.repository.entity;

import jakarta.persistence.Table;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.*;
import org.hibernate.envers.Audited;

import java.io.Serializable;

@Getter
@Setter
@With
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
@Audited
//@Entity
@DynamicUpdate
@Table(name = "file_metadata_attributes")
@ToString
public class FileMetadataAttributes implements Serializable {

    @Id
    @Column(name = "name")
    private String name;

    @Column(name = "value")
    private String value;

    @Id
    @ToString.Exclude
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "file_id")
    @Fetch(FetchMode.SELECT)
    @Cascade({
            CascadeType.PERSIST,
            CascadeType.MERGE,
            CascadeType.REMOVE,
            CascadeType.DETACH,
            CascadeType.REFRESH
    })
    private FileMetadata file;

    @Getter
    @Setter
    @Embeddable
    public static class Identifier implements Serializable {

        @Column(name = "name")
        private String name;

        @Column(name = "file_id")
        private String fileId;

    }

}
