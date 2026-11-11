package com.cap46.backend.dto;

public record CreateDeploymentEventRequest(
        String eventType,
        String description,
        String status
) {
}