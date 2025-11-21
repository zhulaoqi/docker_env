#!/bin/bash

# ========================================
# 配置区域 - 请修改为您的信息
# ========================================
DOCKERHUB_USERNAME="jinqi33333"    # 改成您的 Docker Hub 用户名
IMAGE_NAME="playwright-chrome-cdp"         # 镜像名称
VERSION="1.56.7"                           # 版本号
LATEST_TAG="latest"                        # latest 标签

# ========================================
# 自动生成的变量
# ========================================
FULL_IMAGE="${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "🚀 构建并推送 Playwright Chrome CDP 镜像"
echo "=========================================="
echo ""
echo "配置信息："
echo "  Docker Hub 用户: ${DOCKERHUB_USERNAME}"
echo "  镜像名称: ${IMAGE_NAME}"
echo "  版本号: ${VERSION}"
echo "  完整镜像: ${FULL_IMAGE}:${VERSION}"
echo "  构建时间: ${BUILD_DATE}"
echo ""

# 检查必需文件
if [ ! -f "Dockerfile-chrome" ]; then
    echo -e "${RED}❌ 错误: 找不到 Dockerfile-chrome${NC}"
    exit 1
fi


# 1. 构建镜像
echo -e "${YELLOW}步骤 1/4: 构建镜像...${NC}"
docker build \
    -f Dockerfile-chrome \
    -t ${IMAGE_NAME}:${VERSION} \
    .

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 构建失败！${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 构建成功！${NC}"
echo ""

# 2. 打标签
echo -e "${YELLOW}步骤 2/4: 打标签...${NC}"
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE}:${VERSION}
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE}:${LATEST_TAG}

echo -e "${GREEN}✅ 标签已创建：${NC}"
echo "  - ${FULL_IMAGE}:${VERSION}"
echo "  - ${FULL_IMAGE}:${LATEST_TAG}"
echo ""

# 3. 登录 Docker Hub
echo -e "${YELLOW}步骤 3/4: 登录 Docker Hub...${NC}"
echo "请输入您的 Docker Hub 密码："
docker login -u ${DOCKERHUB_USERNAME}

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 登录失败！${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 登录成功${NC}"
echo ""

# 4. 推送镜像
echo -e "${YELLOW}步骤 4/4: 推送镜像到 Docker Hub...${NC}"
echo "推送版本镜像: ${FULL_IMAGE}:${VERSION}"
docker push ${FULL_IMAGE}:${VERSION}

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 推送版本镜像失败！${NC}"
    exit 1
fi

echo "推送 latest 镜像: ${FULL_IMAGE}:${LATEST_TAG}"
docker push ${FULL_IMAGE}:${LATEST_TAG}

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 推送 latest 镜像失败！${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ 镜像推送成功！${NC}"
echo "=========================================="
echo ""
echo "📦 镜像信息："
echo "  - ${FULL_IMAGE}:${VERSION}"
echo "  - ${FULL_IMAGE}:${LATEST_TAG}"
echo ""
echo "🔗 Docker Hub 地址："
echo "  https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
echo ""
echo "📖 使用方式："
echo "  docker pull ${FULL_IMAGE}:${VERSION}"
echo "  docker run -d -p 9222:9222 ${FULL_IMAGE}:${VERSION}"
echo ""
echo "🧪 测试镜像："
echo "  docker run --rm -p 9222:9222 ${FULL_IMAGE}:${VERSION}"
echo "  curl http://localhost:9222/json/version"
echo "=========================================="