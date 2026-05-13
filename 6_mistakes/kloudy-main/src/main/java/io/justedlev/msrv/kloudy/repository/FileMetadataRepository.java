package io.justedlev.msrv.kloudy.repository;

import io.justedlev.msrv.kloudy.repository.entity.FileMetadata;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.repository.history.RevisionRepository;

import java.math.BigInteger;
import java.util.UUID;

public interface FileMetadataRepository
        extends JpaRepository<FileMetadata, UUID>,
        JpaSpecificationExecutor<FileMetadata>,
        RevisionRepository<FileMetadata, UUID, BigInteger> {
}
