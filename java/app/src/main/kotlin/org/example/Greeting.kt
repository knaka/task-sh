package org.example

import picocli.CommandLine.Command

@Command(
    name = "ktgreet",
    mixinStandardHelpOptions = true,
    version = ["KotlinGreeting 1.0"],
    description = ["Prints a greeting to the console"],
)
class KotlinGreeting : Runnable {
    override fun run() {
        println("Hello from Kotlin18!")
    }
}
