
package com.cap46.backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
public class BackendInfoController {

    @GetMapping("/api/info")
    public Map<String, Object> getBackendInfo() {

        return Map.of(
                "application", "CAP-46 Backend",
                "service", "Spring Boot",
                "status", "RUNNING",
                "version", "1.0.0",
                "timestamp", Instant.now().toString()
        );
    }
}
