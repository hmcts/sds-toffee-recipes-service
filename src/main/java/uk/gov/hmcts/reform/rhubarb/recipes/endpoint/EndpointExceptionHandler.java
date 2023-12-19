package uk.gov.hmcts.reform.rhubarb.recipes.endpoint;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.ServletRequestBindingException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.ErrorResult;
import uk.gov.hmcts.reform.rhubarb.recipes.exception.NoRecipeFoundException;

import static java.util.Collections.emptyList;
import static java.util.Collections.singletonList;
import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR;
import static org.springframework.http.HttpStatus.NOT_FOUND;
import static uk.gov.hmcts.reform.rhubarb.recipes.domain.ErrorCode.BAD_ARGUMENT;
import static uk.gov.hmcts.reform.rhubarb.recipes.domain.ErrorCode.INVALID_AUTH_TOKEN;
import static uk.gov.hmcts.reform.rhubarb.recipes.domain.ErrorCode.NO_RECORD_FOUND;
import static uk.gov.hmcts.reform.rhubarb.recipes.domain.ErrorCode.SERVER_ERROR;

@ControllerAdvice
public class EndpointExceptionHandler extends ResponseEntityExceptionHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(EndpointExceptionHandler.class);

    @Override
    protected ResponseEntity<Object> handleServletRequestBindingException(
        ServletRequestBindingException ex,
        HttpHeaders headers,
        HttpStatusCode status,
        WebRequest request
    ) {
        LOGGER.error(ex.getMessage(), ex);

        return new ResponseEntity<>(
            new ErrorResult(INVALID_AUTH_TOKEN, singletonList("Authorization header is required.")),
            BAD_REQUEST
        );
    }

    @Override
    protected ResponseEntity<Object> handleHttpMessageNotReadable(
        HttpMessageNotReadableException ex,
        HttpHeaders headers,
        HttpStatusCode status,
        WebRequest request
    ) {
        LOGGER.error(ex.getMessage(), ex);

        return new ResponseEntity<>(
            new ErrorResult(BAD_ARGUMENT, singletonList("The draft document is required.")),
            BAD_REQUEST
        );
    }

    @Override
    protected ResponseEntity<Object> handleExceptionInternal(
        Exception ex,
        Object body,
        HttpHeaders headers,
        HttpStatusCode status,
        WebRequest request
    ) {
        LOGGER.error(ex.getMessage(), ex);
        return super.handleExceptionInternal(ex, body, headers, status, request);
    }


    @ExceptionHandler(NoRecipeFoundException.class)
    public ResponseEntity<ErrorResult> handleNoDocumentFoundException(HttpServletRequest req, Exception exception) {
        LOGGER.debug("no draft document found for user.");

        return new ResponseEntity<>(
            new ErrorResult(NO_RECORD_FOUND, singletonList(exception.getMessage())),
            NOT_FOUND
        );
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResult> unknownException(HttpServletRequest req, Exception exception) {
        LOGGER.error(exception.getMessage(), exception);
        return new ResponseEntity<>(
            new ErrorResult(SERVER_ERROR, emptyList()),
            INTERNAL_SERVER_ERROR
        );
    }

}
