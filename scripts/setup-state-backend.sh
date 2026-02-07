#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Setting up Terraform State Backend in Azure...${NC}\n"

# Variables
RESOURCE_GROUP="terraform-state-rg"
LOCATION="eastus"
STORAGE_ACCOUNT="tfstate$(date +%s)"  # Timestamp ensures uniqueness
CONTAINER_NAME="tfstate"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container: $CONTAINER_NAME"
echo ""

# Check if already logged in
echo -e "${YELLOW}Checking Azure authentication...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Azure. Please run 'az login' first.${NC}"
    exit 1
fi

CURRENT_SUB=$(az account show --query name -o tsv)
echo -e "${GREEN}✅ Authenticated to subscription: $CURRENT_SUB${NC}\n"

# Create Resource Group
echo -e "${YELLOW}Creating Resource Group...${NC}"
if az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --output none; then
    echo -e "${GREEN}✅ Resource Group created: $RESOURCE_GROUP${NC}\n"
else
    echo -e "${RED}❌ Failed to create Resource Group${NC}"
    exit 1
fi

# Create Storage Account
echo -e "${YELLOW}Creating Storage Account (this may take 1-2 minutes)...${NC}"
if az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none; then
    echo -e "${GREEN}✅ Storage Account created: $STORAGE_ACCOUNT${NC}\n"
else
    echo -e "${RED}❌ Failed to create Storage Account${NC}"
    exit 1
fi

# Create Container
echo -e "${YELLOW}Creating Blob Container...${NC}"
if az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login \
  --output none; then
    echo -e "${GREEN}✅ Container created: $CONTAINER_NAME${NC}\n"
else
    echo -e "${RED}❌ Failed to create Container${NC}"
    exit 1
fi

# Enable Versioning (for disaster recovery)
echo -e "${YELLOW}Enabling blob versioning...${NC}"
if az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --enable-versioning true \
  --output none; then
    echo -e "${GREEN}✅ Blob versioning enabled${NC}\n"
else
    echo -e "${YELLOW}⚠️  Warning: Could not enable versioning (non-critical)${NC}\n"
fi

# Get Storage Account Key (for backend configuration)
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

# Save configuration to files
echo -e "${YELLOW}Saving backend configuration...${NC}"

# Save to .env file (for reference)
cat > backend-config.env << ENVEOF
# Azure Storage Backend Configuration
# Generated: $(date)

RESOURCE_GROUP=$RESOURCE_GROUP
STORAGE_ACCOUNT=$STORAGE_ACCOUNT
CONTAINER_NAME=$CONTAINER_NAME
LOCATION=$LOCATION
ENVEOF

# Create backend config for dev environment
mkdir -p environments/dev
cat > environments/dev/backend-config.hcl << HCLEOF
# Terraform Backend Configuration for DEV
# Generated: $(date)

resource_group_name  = "$RESOURCE_GROUP"
storage_account_name = "$STORAGE_ACCOUNT"
container_name       = "$CONTAINER_NAME"
key                  = "dev/cloudmart.tfstate"
use_azuread_auth     = true
HCLEOF

# Create backend config for staging environment
mkdir -p environments/staging
cat > environments/staging/backend-config.hcl << HCLEOF
# Terraform Backend Configuration for STAGING
# Generated: $(date)

resource_group_name  = "$RESOURCE_GROUP"
storage_account_name = "$STORAGE_ACCOUNT"
container_name       = "$CONTAINER_NAME"
key                  = "staging/cloudmart.tfstate"
use_azuread_auth     = true
HCLEOF

# Create backend config for prod environment (same storage for now, different key)
mkdir -p environments/prod
cat > environments/prod/backend-config.hcl << HCLEOF
# Terraform Backend Configuration for PROD
# Generated: $(date)
# NOTE: In production, use a separate storage account!

resource_group_name  = "$RESOURCE_GROUP"
storage_account_name = "$STORAGE_ACCOUNT"
container_name       = "$CONTAINER_NAME"
key                  = "prod/cloudmart.tfstate"
use_azuread_auth     = true
HCLEOF

echo -e "${GREEN}✅ Backend configuration files created${NC}\n"

# Create .gitignore
cat > .gitignore << 'GITEOF'
# Terraform files
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
*.tfplan
*.tfvars
!terraform.tfvars.example

# Backend config (contains sensitive info)
backend-config.env

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
GITEOF

echo -e "${GREEN}✅ .gitignore created${NC}\n"

# Display summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ SETUP COMPLETE!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}📋 Summary:${NC}"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container: $CONTAINER_NAME"
echo "  Location: $LOCATION"
echo ""

echo -e "${YELLOW}📁 Files Created:${NC}"
echo "  ✓ backend-config.env (reference only, not for use)"
echo "  ✓ environments/dev/backend-config.hcl"
echo "  ✓ environments/staging/backend-config.hcl"
echo "  ✓ environments/prod/backend-config.hcl"
echo "  ✓ .gitignore"
echo ""

echo -e "${YELLOW}🔐 Access Configuration:${NC}"
echo "  You'll use Azure AD authentication (use_azuread_auth = true)"
echo "  No need to manage storage account keys manually"
echo ""

echo -e "${YELLOW}⚡ Next Steps:${NC}"
echo "  1. cd environments/dev"
echo "  2. Create your Terraform configuration files"
echo "  3. Run: terraform init -backend-config=backend-config.hcl"
echo ""

echo -e "${YELLOW}💡 Verify in Azure Portal:${NC}"
echo "  https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/overview"
echo ""
