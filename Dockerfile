# Custom n8n with ImageMagick for AWS EC2 ARM64
# Built with GitHub Actions - Multi-architecture support

FROM n8nio/n8n:latest

USER root

# ImageMagick + dependencies for PDF processing
RUN apk add --no-cache \
    imagemagick \
    ghostscript \
    poppler-utils \
    && rm -rf /var/cache/apk/*

# Enable PDF processing by modifying ImageMagick policy
RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-7/policy.xml \
    && sed -i '/<policy domain="coder" rights="none" pattern="PDF"/d' /etc/ImageMagick-7/policy.xml

USER node

EXPOSE 5678
