package ma.skylark.msd.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Map;

@RestController
@RequestMapping("/api/chatbot")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatbotController {

    private final WebClient webClient = WebClient.builder().build();

    @Value("${app.ai-service.url}")
    private String aiServiceUrl;

    /**
     * Endpoint simplifié (non-streaming) pour une meilleure fiabilité.
     * Communique avec le service Python qui gère l'IA.
     */
    @PostMapping(value = "/ask", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<Map> askChatbot(@RequestBody Map<String, String> request) {
        // L'URL dans application.yaml doit pointer vers /chat (au lieu de /chat/stream)
        String url = aiServiceUrl.replace("/stream", "");
        
        return webClient.post()
                .uri(url)
                .bodyValue(request)
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .bodyToMono(Map.class)
                .onErrorResume(e -> Mono.just(Map.of(
                        "text", "Erreur: Le service IA est indisponible actuellement.",
                        "route", null
                )));
    }
}
