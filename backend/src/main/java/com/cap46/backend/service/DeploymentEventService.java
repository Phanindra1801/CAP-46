package com.cap46.backend.service;

import com.cap46.backend.entity.DeploymentEvent;
import com.cap46.backend.repository.DeploymentEventRepository;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DeploymentEventService {

    private final DeploymentEventRepository repository;

    public DeploymentEventService(DeploymentEventRepository repository) {
        this.repository = repository;
    }

    public DeploymentEvent createEvent(
            String eventType,
            String description,
            String status) {

        DeploymentEvent event = new DeploymentEvent();

        event.setEventType(eventType);
        event.setDescription(description);
        event.setStatus(status);

        return repository.save(event);
    }

    public List<DeploymentEvent> getAllEvents() {
        return repository.findAll();
    }

}