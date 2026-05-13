package io.justedlev.msrv.kloudy.controller;

import jakarta.persistence.EntityNotFoundException;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.http.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.Map;
import java.util.Optional;
import java.util.function.Supplier;

@Slf4j
@RestControllerAdvice
@RequiredArgsConstructor
public class GeneralExceptionHandler extends ResponseEntityExceptionHandler {

    private static final Supplier<String> EMPTY_STRING = () -> "";

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<Object>
    handleEntityNotFoundException(@NonNull EntityNotFoundException ex, @NonNull WebRequest request) {
        log.error(ex.getMessage(), ex);
        var status = HttpStatus.NOT_FOUND;
        var body = getBody(ex, request, status);

        return handleExceptionInternal(ex, body, new HttpHeaders(), status, request);
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
            @NonNull MethodArgumentNotValidException ex,
            @NonNull HttpHeaders headers,
            @NonNull HttpStatusCode status,
            @NonNull WebRequest request
    ) {
        log.error(ex.getMessage(), ex);
        var errors = ex.getFieldErrors()
                .stream()
                .map(fe -> Map.of(
                        "field", fe.getField(),
                        "message", ObjectUtils.toString(fe.getDefaultMessage(), EMPTY_STRING),
                        "value", ObjectUtils.toString(fe.getRejectedValue(), EMPTY_STRING),
                        "rejectedValue", ObjectUtils.toString(fe.getRejectedValue(), EMPTY_STRING)
                ))
                .toList();
        ex.getBody().setProperty("errors", errors);

        return handleExceptionInternal(ex, null, headers, status, request);
    }

    private ProblemDetail getBody(Exception ex, WebRequest request, HttpStatus status) {
        return Optional.ofNullable(getMessageSource())
                .map(ms -> ms.getMessage(
                        ex.getClass().getName(),
                        null,
                        ex.getMessage(),
                        request.getLocale()
                ))
                .map(msg -> ProblemDetail.forStatusAndDetail(status, msg))
                .orElseGet(() -> ProblemDetail.forStatusAndDetail(status, ex.getMessage()));
    }

}
