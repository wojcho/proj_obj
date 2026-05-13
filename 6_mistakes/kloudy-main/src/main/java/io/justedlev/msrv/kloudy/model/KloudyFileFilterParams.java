package io.justedlev.msrv.kloudy.model;

import io.swagger.v3.oas.annotations.Parameter;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Accessors(chain = true)
@lombok.Builder(builderClassName = "Builder")
public class KloudyFileFilterParams implements Serializable {

    @Parameter(description = "Free text")
    private String q;

}
