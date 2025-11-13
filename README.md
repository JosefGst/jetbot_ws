
# 🤖 Jetbot Diffdrive ROS2

![diy-jetbot](./assets/diy-jetbot.jpeg)

## 🐳 Docker Setup
```bash
mkdir -p ~/ros && cd ~/ros
git clone git@github.com:JosefGst/jetbot_ws.git
cd jetbot_ws/docker
docker compose -f docker-compose.yaml build
```

## 🚀 Start the Bringup
```bash
docker compose -f docker-compose.yaml up launch_bringup
```

## 💻 Development Container
```bash
docker compose -f docker-compose.yaml up dev
```

## 🔗 Connect to the Dev Container
```bash
docker exec -it dev bash
```