package io.justedlev.msrv.kloudy.controller;

import io.justedlev.msrv.kloudy.model.KloudyFileFilterParams;
import io.justedlev.msrv.kloudy.model.KloudyFileResponse;
import io.justedlev.msrv.kloudy.service.KloudyFileService;
import io.justedlev.sb3c.DefaultAuditable_;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springdoc.core.converters.models.PageableAsQueryParam;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PagedModel;
import org.springframework.data.web.SortDefault;
import org.springframework.http.*;
import org.springframework.util.AntPathMatcher;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;

@Tag(name = "Files", description = "Files API v1")
@RestController
@RequestMapping(FilesController.CONTEXT_PATH)
@RequiredArgsConstructor
@Validated
public class FilesController {
    public static final String CONTEXT_PATH = "/v1/files"; //NOSONAR

    private static final Set<String> INLINE_MEDIA_TYPES = Set.of("video", "image", "audio");

    private final KloudyFileService kloudyFileService;

    @Operation(
            summary = "Upload file",
            description = "Upload the single Kloudy file",
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "The file that can be uploaded"
            )
    )
    @ApiResponse(responseCode = "201")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<KloudyFileResponse> upload(@RequestPart(name = "f") @NotNull MultipartFile file) {
        var res = kloudyFileService.upload(file);
        var location = UriComponentsBuilder.fromPath(CONTEXT_PATH)
                .path(AntPathMatcher.DEFAULT_PATH_SEPARATOR + res.id())
                .build()
                .toUri();

        return ResponseEntity.created(location).body(res);
    }

    @Operation(
            summary = "Get file",
            description = "Retrieve a Kloudy file info by ID",
            parameters = {
                    @Parameter(name = "id", description = "Unique identifier of file"),
            }
    )
    @ApiResponse(responseCode = "200")
    @ApiResponse(
            responseCode = "404",
            content = @Content(
                    mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE,
                    schema = @Schema(implementation = ProblemDetail.class)
            )
    )
    @GetMapping(value = "/{id}")
    public ResponseEntity<KloudyFileResponse> get(@PathVariable @NotNull UUID id) {
        return ResponseEntity.ok(kloudyFileService.getOne(id));
    }

    @Operation(summary = "Retrieve files by search", description = "Get a sliced list of Kloudy file (page)")
    @ApiResponse(responseCode = "200")
    @ApiResponse(
            responseCode = "400",
            content = @Content(
                    mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE,
                    schema = @Schema(implementation = ProblemDetail.class)
            )
    )
    @PageableAsQueryParam
    @GetMapping(value = "/search")
    public ResponseEntity<PagedModel<KloudyFileResponse>> search(
            @ParameterObject
            @Valid
            KloudyFileFilterParams params,
            @ParameterObject
            @SortDefault(value = DefaultAuditable_.CREATED_AT, direction = Sort.Direction.DESC)
            Pageable pageable
    ) {
        return ResponseEntity.ok(kloudyFileService.findAll(params, pageable));
    }

    @Operation(summary = "Download file", parameters = {
            @Parameter(name = "id", description = "Unique identifier of file"),
    })
    @ApiResponse(
            responseCode = "200",
            content = @Content(mediaType = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    )
    @ApiResponse(
            responseCode = "404",
            content = @Content(
                    mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE,
                    schema = @Schema(implementation = ProblemDetail.class)
            )
    )
    @GetMapping(value = "/{id}/download")
    public ResponseEntity<StreamingResponseBody> download(@PathVariable @NonNull UUID id) {
        var res = kloudyFileService.download(id);
        var contentDisposition = Optional.ofNullable(res.getContentType())
                .map(MediaType::getType)
                .filter(INLINE_MEDIA_TYPES::contains)
                .map(c -> ContentDisposition.inline())
                .orElseGet(ContentDisposition::attachment)
                .filename(res.getFilename())
                .build()
                .toString();

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, contentDisposition)
                .contentLength(res.getLength())
                .contentType(res.getContentType())
                .body(out -> out.write(res.getResource().getContentAsByteArray()));
    }

    @Operation(summary = "Delete file", parameters = {
            @Parameter(name = "id", description = "Unique identifier of file"),
    })
    @ApiResponse(responseCode = "204")
    @ApiResponse(
            responseCode = "404",
            content = @Content(
                    mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE,
                    schema = @Schema(implementation = ProblemDetail.class)
            )
    )
    @DeleteMapping(value = "/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        kloudyFileService.delete(id);
        return ResponseEntity.noContent().build();
    }

}
