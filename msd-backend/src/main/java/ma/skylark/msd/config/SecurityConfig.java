package ma.skylark.msd.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


/**
 * Configures OAuth2 Resource Server with JWT validation against Keycloak.
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity 
public class SecurityConfig {

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
                http
                        .csrf(csrf -> csrf.disable())
                        .cors(Customizer.withDefaults())
                        .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                        .authorizeHttpRequests(auth -> auth
                                .requestMatchers(HttpMethod.POST,
                                        "/api/auth/signup",
                                        "/api/auth/login",
                                        "/api/auth/forgot-password",
                                        "/api/auth/refresh").permitAll()
                                .requestMatchers("/swagger-ui/**", "/swagger-ui.html", "/v3/api-docs/**").permitAll()
                                .requestMatchers("/api/uploads/**").permitAll() // Autoriser l'accès aux images

                                // Accès restreint Admin
                                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                                .requestMatchers("/api/pricing/admin/**").hasRole("ADMIN")

                                // Pricing pour professionnels
                                .requestMatchers("/api/pricing/professional/**").hasRole("PROFESSIONAL")

                                .requestMatchers("/api/professional/search").hasAnyRole("PROFESSIONAL", "PATIENT", "ADMIN")
                                .requestMatchers(HttpMethod.GET, "/api/professional/*/available-slots").hasAnyRole("PROFESSIONAL", "PATIENT", "ADMIN")
                                .requestMatchers("/api/professional/**").hasRole("PROFESSIONAL")

                                .anyRequest().authenticated())
                        .oauth2ResourceServer(oauth2 -> oauth2
                                .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())));

                return http.build();
        }

        @Bean
        public JwtAuthenticationConverter jwtAuthenticationConverter() {
                JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
                converter.setJwtGrantedAuthoritiesConverter(jwt -> {
                        JwtGrantedAuthoritiesConverter defaultConverter = new JwtGrantedAuthoritiesConverter();
                        Collection authorities = new ArrayList<>(defaultConverter.convert(jwt));

                        Map<String, Object> realmAccess = jwt.getClaim("realm_access");
                        if (realmAccess != null && realmAccess.containsKey("roles")) {
                                List<String> roles = (List<String>) realmAccess.get("roles");
                                authorities.addAll(roles.stream()
                                        .map(role -> "ROLE_" + role.toUpperCase()) 
                                        .map(org.springframework.security.core.authority.SimpleGrantedAuthority::new)
                                        .collect(Collectors.toList()));
                        }
                        return authorities;
                });
                return converter;
        }

        @Bean
        public CorsConfigurationSource corsConfigurationSource() {
                CorsConfiguration configuration = new CorsConfiguration();
                configuration.setAllowedOrigins(List.of("http://localhost:3000", "http://localhost:4200", "http://localhost:8081", "*"));
                configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
                configuration.setAllowedHeaders(List.of("Authorization", "Content-Type", "X-Requested-With", "Accept"));
                configuration.setAllowCredentials(true);
                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
                source.registerCorsConfiguration("/**", configuration);
                return source;
        }
}
