# Multi-stage Dockerfile for Android APK development with Kotlin and C++
# Build toolchain: Android Studio, JBR, NDK, JDK

FROM ubuntu:22.04

LABEL maintainer="Android Developer" \
      description="Docker image for building Android APK with Kotlin and C++ support"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android \
    NDK_HOME=/opt/android/ndk \
    JAVA_HOME=/opt/jdk \
    JBR_HOME=/opt/jbr \
    PATH=$PATH:/opt/jdk/bin:/opt/jbr/bin:/opt/android/cmdline-tools/latest/bin:/opt/gradle/bin \
    GRADLE_USER_HOME=/root/.gradle

# Update and install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    zip \
    openjdk-17-jdk-headless \
    openjdk-17-jre-headless \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-dev \
    cmake \
    ninja-build \
    pkg-config \
    libncurses5 \
    libc6-i386 \
    lib32stdc++6 \
    lib32gcc1 \
    lib32ncurses6 \
    lib32z1 \
    apt-transport-https \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p ${ANDROID_HOME} \
    && mkdir -p ${JAVA_HOME} \
    && mkdir -p ${JBR_HOME} \
    && mkdir -p /workspace

# Install JDK 17
RUN cd /tmp && \
    wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8.1%2B1/OpenJDK17U-jdk_x64_linux_hotspot_17.0.8.1_1.tar.gz && \
    tar -xzf OpenJDK17U-jdk_x64_linux_hotspot_17.0.8.1_1.tar.gz -C ${JAVA_HOME} --strip-components=1 && \
    rm OpenJDK17U-jdk_x64_linux_hotspot_17.0.8.1_1.tar.gz

# Install JetBrains Runtime (JBR) 17
RUN cd /tmp && \
    wget https://cache-redirector.jetbrains.com/intellij-jbr/jbr_dcevm-17.0.8-linux-x64-b1038.25.tar.gz && \
    tar -xzf jbr_dcevm-17.0.8-linux-x64-b1038.25.tar.gz -C ${JBR_HOME} --strip-components=1 && \
    rm jbr_dcevm-17.0.8-linux-x64-b1038.25.tar.gz

# Install Android SDK Command-line Tools
RUN cd /tmp && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip -q commandlinetools-linux-9477386_latest.zip -d ${ANDROID_HOME} && \
    rm commandlinetools-linux-9477386_latest.zip && \
    mkdir -p ${ANDROID_HOME}/cmdline-tools/latest && \
    mv ${ANDROID_HOME}/cmdline-tools/* ${ANDROID_HOME}/cmdline-tools/latest/ 2>/dev/null || true

# Accept Android SDK licenses and install components
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_HOME} \
    "platform-tools" \
    "build-tools;34.0.0" \
    "platforms;android-34" \
    "platforms;android-33" \
    "platforms;android-32" \
    "emulator" \
    "cmake;3.22.1"

# Install Android NDK (latest LTS version)
RUN ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_HOME} \
    "ndk;25.2.9519653"

# Create symlink for NDK
RUN ln -sf ${ANDROID_HOME}/ndk/25.2.9519653 ${NDK_HOME}

# Install Gradle
RUN cd /tmp && \
    wget https://services.gradle.org/distributions/gradle-8.4-bin.zip && \
    unzip -q gradle-8.4-bin.zip -d /opt && \
    rm gradle-8.4-bin.zip && \
    ln -s /opt/gradle-8.4 /opt/gradle

# Set permissions
RUN chmod -R 755 ${ANDROID_HOME} \
    && chmod -R 755 ${JAVA_HOME} \
    && chmod -R 755 ${JBR_HOME} \
    && chmod -R 755 /opt/gradle

# Verify installations
RUN java -version && \
    ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --version && \
    gradle -version

# Set working directory
WORKDIR /workspace

# Create a helper script for building
RUN cat > /usr/local/bin/build-apk.sh << 'EOF'
#!/bin/bash
set -e

echo "Android APK Build Environment"
echo "=============================="
echo "Java Version:"
java -version
echo ""
echo "Android SDK Location: $ANDROID_HOME"
echo "NDK Location: $NDK_HOME"
echo "JBR Location: $JBR_HOME"
echo "Gradle Version:"
gradle -version
echo ""
echo "Available Android Platforms:"
ls -la $ANDROID_HOME/platforms/
echo ""
echo "Available NDK Versions:"
ls -la $ANDROID_HOME/ndk/
echo ""
echo "To build your project, run: gradle build"
EOF

RUN chmod +x /usr/local/bin/build-apk.sh

# Default command
CMD ["build-apk.sh"]
