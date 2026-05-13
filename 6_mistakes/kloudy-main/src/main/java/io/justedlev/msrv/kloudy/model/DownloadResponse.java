package io.justedlev.msrv.kloudy.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
public class DownloadResponse {

    private String filename;
    private String extension;
    @Builder.Default
    private MediaType contentType = MediaType.APPLICATION_OCTET_STREAM;
    @Builder.Default
    private Long length = 0L;
    private Resource resource;

}
