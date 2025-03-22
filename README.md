# Assignment 3: Create a Local VM and Auto-Scale It to GCP or Any Other Public Cloud When Resource Usage Exceeds 75%

This project implements an automated resource monitoring system on a Puppy Linux VM that triggers auto-scaling to Google Cloud Platform when local resource usage exceeds a defined threshold.

## Overview

When the CPU or memory utilization on the local Puppy Linux VM exceeds 75%, the system automatically provisions a new virtual machine instance in Google Cloud Platform and deploys a basic web server, effectively scaling to the cloud.

![System Architecture](/detailed-architecture.png)

![Overall FLow]](/flow.png)


## Prerequisites

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (or similar virtualization software)
- [Puppy Linux](https://puppylinux-woof-ce.github.io/) ISO (FossaPup 9.5 recommended)
- Google Cloud Platform account with billing enabled
- Google Cloud SDK installed on your Puppy Linux VM
- Basic knowledge of Linux command line

## Files Included

- `monitor.sh`: Monitors CPU and memory usage on the local VM
- `scale_to_gcp.sh`: Creates a new instance in GCP when resource thresholds are exceeded
- `load_generation.sh`: Test script to generate CPU load for testing purposes

## Installation

### 1. Setting Up the Local VM

1. **Create a VM in VirtualBox**
   ```
   - Download Puppy Linux ISO
   - Open VirtualBox and click "New"
   - Configure the VM with the following settings:
     - Name: PuppyLinux
     - Type: Linux
     - Version: Other Linux (64-bit)
     - Memory: 1024 MB (Puppy Linux is lightweight)
     - Hard disk: 10 GB (VDI, dynamically allocated)
     - Processors: 2 CPUs
     - Network: Bridged Adapter
   ```

2. **Install Puppy Linux**
   ```
   - Start the VM and boot from the ISO
   - Follow the installation wizard
   - Choose Universal Installation
   - Install GRUB bootloader when prompted
   - Complete the installation and restart
   ```

3. **Initial Configuration**
   ```bash
   # Update the system
   sudo ppm update
   
   # Install required tools
   sudo ppm install git curl wget bc htop
   
   # Create SSH key for GCP authentication
   ssh-keygen -t rsa -b 4096 -C "puppy-monitoring"
   ```

### 2. GCP Configuration

1. **Install Google Cloud SDK**
   ```bash
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   gcloud init
   ```

2. **Configure Authentication**
   ```bash
   # Follow the prompts to log into your Google account
   gcloud auth login
   
   # Set your project ID
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Upload SSH Keys to GCP**
   ```bash
   # View your public key
   cat ~/.ssh/id_rsa.pub
   
   # Add this key to GCP metadata via the Console:
   # Compute Engine > Metadata > SSH Keys > Add key
   ```

### 3. Implementing Resource Monitoring

1. **Create a Directory for Scripts**
   ```bash
   mkdir -p ~/tools
   cd ~/tools
   ```

2. **Create Monitoring Script**
   ```bash
   # Create monitor.sh file with the provided script content
   nano monitor.sh
   
   # Make it executable
   chmod +x monitor.sh
   ```

3. **Create GCP Auto-Scaling Script**
   ```bash
   # Create scale_to_gcp.sh file with the provided script content
   # Make sure to update PROJECT_ID with your GCP project ID
   nano scale_to_gcp.sh
   
   # Make it executable
   chmod +x scale_to_gcp.sh
   ```

4. **Create Load Generation Script for Testing**
   ```bash
   # Create load_generation.sh file with the provided script content
   nano load_generation.sh
   
   # Make it executable
   chmod +x load_generation.sh
   ```

5. **Schedule Automatic Monitoring**
   ```bash
   # Edit the crontab
   crontab -e
   
   # Add this line to run the monitor every 5 minutes
   */5 * * * * ~/tools/monitor.sh
   ```

## Usage

### Monitoring System Resources

The monitoring script automatically runs every 5 minutes checking CPU and memory usage.

To run it manually:
```bash
cd ~/tools
./monitor.sh
```

### Testing with Load Generation

To test the auto-scaling trigger, you can generate artificial load:
```bash
cd ~/tools
# Generate load for 2 minutes (120 seconds)
./load_generation.sh 120
```

### Verify Auto-Scaling

When the load exceeds the threshold (75%), a new GCP instance will be created automatically.

To verify the new instance:
```bash
gcloud compute instances list
```

You should see a new instance with a name like `auto-scaled-instance-1679428800`.

### Cleaning Up Resources

When you're done testing, remove any auto-scaled instances:
```bash
gcloud compute instances delete INSTANCE_NAME --zone=us-central1-a
```

## How It Works

1. The `monitor.sh` script checks CPU and RAM usage.
2. If either exceeds 75%, it calls `scale_to_gcp.sh`.
3. `scale_to_gcp.sh` creates a new VM instance in GCP.
4. The script installs NGINX web server on the new instance.
5. All events are logged to `~/monitoring.log` and `~/scaling.log`.

## Troubleshooting

### Common Issues

1. **Monitor Script Not Detecting High Usage**
   - Verify `bc` is installed: `which bc`
   - Check threshold settings in `monitor.sh`

2. **GCP Instance Creation Fails**
   - Ensure `gcloud` is properly authenticated
   - Check your GCP project has billing enabled
   - Verify you have sufficient quota for VM instances

3. **Load Generation Not Working**
   - Ensure your VM has sufficient resources allocated
   - Check if `dd` and `md5sum` commands are available

### Checking Logs

Both scripts log their activities:
```bash
# View monitoring log
cat ~/monitoring.log

# View scaling log
cat ~/scaling.log
```

## Customization

### Changing the Threshold

Edit `monitor.sh` and modify the `THRESHOLD` value:
```bash
# Change from 75.0 to your desired value
THRESHOLD=90.0
```

### Changing VM Size in GCP

Edit `scale_to_gcp.sh` and modify the `MACHINE_TYPE`:
```bash
# For a larger instance, change from e2-micro to e2-small or e2-medium
MACHINE_TYPE="e2-medium"
```

## Contributing

Feel free to submit pull requests or open issues to improve the project.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
