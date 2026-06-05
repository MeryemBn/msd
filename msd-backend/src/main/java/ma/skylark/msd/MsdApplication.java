package ma.skylark.msd;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class MsdApplication {

    public static void main(String[] args) {
        SpringApplication.run(MsdApplication.class, args);
    }

}
