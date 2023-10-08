# Use the official Python 3.11 alpine image as the base image
FROM python:3.11-alpine

# Set the working directory to /app
WORKDIR /app

# Copy the rest of the application code into the container
COPY . .

# Install the necessary dependencies
RUN pip install --no-cache-dir -r requirements.txt
# RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
#   && pip install --no-cache-dir -r requirements.txt \
#   && apk del .build-deps gcc musl-dev

# Create a new user to run the application
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change the ownership of the application directory to the new user
RUN chown -R appuser:appgroup /app

# Switch to the new user
USER appuser

# Expose port 80 for the FastAPI app
EXPOSE 80

# Start the FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
