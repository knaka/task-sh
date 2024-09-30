package org.example;

import picocli.CommandLine;
import picocli.CommandLine.*;

@Command(name = "jgreet", mixinStandardHelpOptions = true, version = "JavaGreeting 1.0",
        description = "Prints a greeting to the user.")
class JavaGreeting implements Runnable {
    @Option(names = {"-u", "--user"}, description = "User name")
    private String user;

    @Option(names = {"-h", "--help"}, usageHelp = true, description = "Display this help message")
    private boolean helpRequested = false;

    public void run() {
        if (helpRequested) {
            CommandLine.usage(this, System.out);
            return;
        }
        System.out.println("Hello, " + (user != null ? user : "stranger") + "!");
    }

    public static void main(String[] args) {
        CommandLine.run(new JavaGreeting(), System.out, args);
    }
}
