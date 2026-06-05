package ma.skylark.msd.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.CreateReviewRequest;
import ma.skylark.msd.controller.dto.ReviewResponse;
import ma.skylark.msd.service.ReviewService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping
    public ResponseEntity<Void> submitReview(
            @Valid @RequestBody CreateReviewRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        reviewService.submitReview(request, jwt.getSubject());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/mine")
    public List<ReviewResponse> getMyReviews(@AuthenticationPrincipal Jwt jwt) {
        return reviewService.getMyReviews(jwt.getSubject());
    }

    @GetMapping("/professional/{id}")
    public List<ReviewResponse> getProfessionalReviews(@PathVariable Long id) {
        return reviewService.getProfessionalReviews(id);
    }
}
