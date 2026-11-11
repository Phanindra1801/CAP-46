package com.cap46.backend.controller;

import com.cap46.backend.dto.CreateDeploymentEventRequest;
import com.cap46.backend.entity.DeploymentEvent;
import com.cap46.backend.service.DeploymentEventService;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/deployment-events")
public class DeploymentEventController {

    private final DeploymentEventService service;

    public DeploymentEventController(DeploymentEventService service) {
        this.service = service;
    }

    @PostMapping
    public DeploymentEvent createEvent(
            @RequestBody CreateDeploymentEventRequest request) {

        return service.createEvent(
                request.eventType(),
                request.description(),
                request.status()
        );
    }

    @GetMapping
    public List<DeploymentEvent> getAllEvents() {
        return service.getAllEvents();
    }
}