# =============================================================================
# Ty3r0X's Lair - CI/CD Pipeline buildscript
# =============================================================================

# Configuration
SITE_NAME := ty3r0x-lair
SOURCE_DIR := .
BUILD_DIR := public
TEMPLATES_DIR := templates
CONTENT_DIR := content
SASS_DIR := sass

# Output directories
XHTML_DIR := $(BUILD_DIR)
REPORTS_DIR := reports
TEMP_DIR := .tmp

# Tools (auto-detected)
ZOLA := $(shell command -v zola 2>/dev/null)
XMLLINT := $(shell command -v xmllint 2>/dev/null)
PERL := $(shell command -v perl 2>/dev/null)
FIND := $(shell command -v find 2>/dev/null)
SED := $(shell command -v sed 2>/dev/null || command -v gsed 2>/dev/null)
CURL := $(shell command -v curl 2>/dev/null)

RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m

# Build metadata
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_HASH := $(shell git rev-parse --short HEAD 2>/dev/null || echo -e "unknown")
BUILD_VERSION := $(shell git describe --tags --always 2>/dev/null || echo -e "dev")

# =============================================================================
# Public Targets
# =============================================================================

.PHONY: help all build validate clean check-deps test deploy-ready
.DEFAULT_GOAL := help

## Show help information
help:
	@echo -e "$(BLUE)$(SITE_NAME) - Pipeline$(NC)"
	@echo -e "======================================"
	@echo -e ""
	@echo -e "$(GREEN)Main Commands:$(NC)"
	@echo -e "  all          - Full build, convert to XHTML, and validate"
	@echo -e "  build        - Build site with Zola"
	@echo -e "  convert      - Convert HTML files to XHTML"
	@echo -e "  validate     - Validate XHTML documents"
	@echo -e "  test         - Run all tests and validations"
	@echo -e "  deploy-ready - Build and validate for deployment"
	@echo -e ""
	@echo -e "$(GREEN)Utilities:$(NC)"
	@echo -e "  clean        - Remove build artifacts"
	@echo -e "  clean-all    - Remove all generated files"
	@echo -e "  check-deps   - Check required dependencies"
	@echo -e "  info         - Show build information"
	@echo -e "  serve        - Start development server"
	@echo -e ""
	@echo -e "$(GREEN)Validation:$(NC)"
	@echo -e "  validate-xhtml    - Validate XHTML syntax"
	@echo -e "  validate-links    - Check for broken links"
	@echo -e "  validate-structure - Validate site structure"
	@echo -e "  generate-report   - Generate validation report"
	@echo -e ""

## Complete build pipeline: build -> convert -> validate
all: check-deps clean build convert validate
	@echo -e "$(GREEN)✓ Complete build pipeline finished successfully!$(NC)"
	@echo -e "$(BLUE)ℹ️  XHTML files ready in $(XHTML_DIR)/$(NC)"

## Build site for deployment (same as all)
deploy-ready: all
	@echo -e "$(GREEN)✓ Site ready for deployment$(NC)"

## Run comprehensive tests
test: all validate-links validate-structure
	@echo -e "$(GREEN)✓ All tests passed$(NC)"

# =============================================================================
# Build Targets
# =============================================================================

## Check dependencies
check-deps:
	@echo -e "$(BLUE)🔍 Checking dependencies...$(NC)"
ifndef ZOLA
	@echo -e "$(RED)✗ Error: zola not found$(NC)" && \
	echo -e "  Install from: https://www.getzola.org/" && exit 1
endif
ifndef XMLLINT
	@echo -e "$(YELLOW)⚠️  Warning: xmllint not found (XHTML validation disabled)$(NC)"
endif
ifndef PERL
	@echo -e "$(RED)✗ Error: perl not found$(NC)" && exit 1
endif
ifndef FIND
	@echo -e "$(RED)✗ Error: find not found$(NC)" && exit 1
endif
ifndef SED
	@echo -e "$(RED)✗ Error: sed not found$(NC)" && exit 1
endif
	@echo -e "$(GREEN)✓ Dependencies check complete$(NC)"

## Build site with Zola
build: check-deps
	@echo -e "$(BLUE)🔨 Building site with Zola...$(NC)"
	@rm -rf $(BUILD_DIR)
	@$(ZOLA) build
	@echo -e "$(GREEN)✓ Zola build complete$(NC)"

## Convert HTML files to XHTML
convert: 
	@echo -e "$(BLUE)🔄 Converting HTML files to XHTML...$(NC)"
	@if [ ! -d "$(BUILD_DIR)" ]; then \
		echo -e "$(RED)✗ Build directory not found. Run 'make build' first$(NC)" && exit 1; \
	fi
	@mkdir -p $(TEMP_DIR)
	@converted=0; \
	total=0; \
	$(FIND) $(BUILD_DIR) -name "*.html" -type f | while read -r file; do \
		total=$$((total + 1)); \
		xhtml_file="$${file%.html}.xhtml"; \
		echo -e "  📄 Converting $$(basename "$$file") → $$(basename "$$xhtml_file")"; \
		if $(SED) \
			-e '1i<?xml version="1.0" encoding="UTF-8"?>' \
			-e 's|<!DOCTYPE html>|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">|' \
			-e 's|<html\([^>]*\)>|<html xmlns="http://www.w3.org/1999/xhtml"\1>|' \
			-e 's|<html>|<html xmlns="http://www.w3.org/1999/xhtml">|' \
			-e 's|<meta charset="utf-8">|<meta http-equiv="content-type" content="text/html; charset=UTF-8" />|' \
			-e 's|<meta \([^>]*[^/]\)>|<meta \1 />|g' \
			-e 's|<link \([^>]*[^/]\)>|<link \1 />|g' \
			-e 's|<img \([^>]*[^/]\)>|<img \1 />|g' \
			-e 's|<input \([^>]*[^/]\)>|<input \1 />|g' \
			-e 's|<source \([^>]*[^/]\)>|<source \1 />|g' \
			-e 's|<area \([^>]*[^/]\)>|<area \1 />|g' \
			-e 's|<base \([^>]*[^/]\)>|<base \1 />|g' \
			-e 's|<br[^>]*>|<br />|g' \
			-e 's|<hr[^>]*>|<hr />|g' \
			-e 's|<wbr[^>]*>|<wbr />|g' \
			-e 's| />/>| />|g' \
			"$$file" > "$$xhtml_file"; then \
			rm "$$file"; \
			converted=$$((converted + 1)); \
		else \
			echo -e "$(RED)✗ Error converting $$file$(NC)"; \
			exit 1; \
		fi; \
	done
	@echo -e "$(GREEN)✓ HTML to XHTML conversion complete$(NC)"

# =============================================================================
# Validation Targets
# =============================================================================

## Validate XHTML documents
validate: validate-xhtml validate-structure
	@echo -e "$(GREEN)✓ All validations complete$(NC)"

## Validate XHTML syntax using xmllint
validate-xhtml:
	@echo -e "$(BLUE)🔍 Validating XHTML syntax...$(NC)"
	@mkdir -p $(REPORTS_DIR)
ifdef XMLLINT
	@error_count=0; \
	total_count=0; \
	$(FIND) $(BUILD_DIR) -name "*.xhtml" -type f | while read -r file; do \
		total_count=$$((total_count + 1)); \
		if $(XMLLINT) --noout --valid "$$file" 2>/dev/null; then \
			echo -e "  ✓ $$(basename "$$file")"; \
		else \
			echo -e "  $(RED)✗ $$(basename "$$file")$(NC)"; \
			$(XMLLINT) --noout --valid "$$file" 2>&1 | head -3; \
			error_count=$$((error_count + 1)); \
		fi; \
	done; \
	if [ $$error_count -gt 0 ]; then \
		echo -e "$(RED)✗ $$error_count XHTML validation errors found$(NC)"; \
		exit 1; \
	else \
		echo -e "$(GREEN)✓ All XHTML files are valid$(NC)"; \
	fi
else
	@echo -e "$(YELLOW)⚠️  xmllint not available, skipping XHTML validation$(NC)"
endif

## Validate site structure
validate-structure:
	@echo -e "$(BLUE)🏗️  Validating site structure...$(NC)"
	@error_count=0; \
	\
	if [ ! -f "$(BUILD_DIR)/index.xhtml" ]; then \
		echo -e "$(RED)✗ Missing index.xhtml$(NC)"; \
		error_count=$$((error_count + 1)); \
	else \
		echo -e "  ✓ index.xhtml exists"; \
	fi; \
	\
	if [ ! -f "$(BUILD_DIR)/main.css" ]; then \
		echo -e "$(RED)✗ Missing main.css$(NC)"; \
		error_count=$$((error_count + 1)); \
	else \
		echo -e "  ✓ main.css exists"; \
	fi; \
	\
	if [ ! -d "$(BUILD_DIR)/blog" ]; then \
		echo -e "$(YELLOW)⚠️  Blog directory missing$(NC)"; \
	else \
		echo -e "  ✓ blog directory exists"; \
	fi; \
	\
	xhtml_count=$$($(FIND) $(BUILD_DIR) -name "*.xhtml" | wc -l); \
	if [ $$xhtml_count -eq 0 ]; then \
		echo -e "$(RED)✗ No XHTML files found$(NC)"; \
		error_count=$$((error_count + 1)); \
	else \
		echo -e "  ✓ Found $$xhtml_count XHTML files"; \
	fi; \
	\
	if [ $$error_count -gt 0 ]; then \
		echo -e "$(RED)✗ $$error_count structure validation errors$(NC)"; \
		exit 1; \
	else \
		echo -e "$(GREEN)✓ Site structure is valid$(NC)"; \
	fi

## Validate internal links
validate-links:
	@echo -e "$(BLUE)🔗 Validating internal links...$(NC)"
	@mkdir -p $(REPORTS_DIR)
	@error_count=0; \
	link_count=0; \
	$(FIND) $(BUILD_DIR) -name "*.xhtml" -type f -exec grep -l 'href=' {} \; | while read -r file; do \
		grep -o 'href="[^"]*"' "$$file" | sed 's/href="//g; s/"//g' | while read -r link; do \
			link_count=$$((link_count + 1)); \
			case "$$link" in \
				http*|https*|mailto*|#*) \
					continue ;; \
				/*) \
					target_file="$(BUILD_DIR)$$link"; \
					if [ "$${link}" = "$${link%.xhtml}" ] && [ "$${link}" = "$${link%.html}" ]; then \
						if [ -f "$$target_file.xhtml" ]; then \
							target_file="$$target_file.xhtml"; \
						elif [ -f "$$target_file/index.xhtml" ]; then \
							target_file="$$target_file/index.xhtml"; \
						fi; \
					fi; \
					if [ ! -f "$$target_file" ] && [ ! -d "$$target_file" ]; then \
						echo -e "  $(RED)✗ Broken link: $$link in $$(basename "$$file")$(NC)"; \
						error_count=$$((error_count + 1)); \
					fi ;; \
			esac; \
		done; \
	done; \
	if [ $$error_count -gt 0 ]; then \
		echo -e "$(RED)✗ $$error_count broken internal links found$(NC)"; \
		exit 1; \
	else \
		echo -e "$(GREEN)✓ All internal links are valid$(NC)"; \
	fi

## Generate validation report
generate-report:
	@echo -e "$(BLUE)📊 Generating validation report...$(NC)"
	@mkdir -p $(REPORTS_DIR)
	@report_file="$(REPORTS_DIR)/validation-report-$$(date +%Y%m%d-%H%M%S).txt"; \
	{ \
		echo -e "=============================================="; \
		echo -e "$(SITE_NAME) Validation Report"; \
		echo -e "=============================================="; \
		echo -e "Generated: $(BUILD_DATE)"; \
		echo -e "Build Version: $(BUILD_VERSION)"; \
		echo -e "Build Hash: $(BUILD_HASH)"; \
		echo -e ""; \
		echo -e "Files Summary:"; \
		echo -e "- XHTML files: $$($(FIND) $(BUILD_DIR) -name "*.xhtml" | wc -l)"; \
		echo -e "- CSS files: $$($(FIND) $(BUILD_DIR) -name "*.css" | wc -l)"; \
		echo -e "- Image files: $$($(FIND) $(BUILD_DIR) \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" -o -name "*.svg" \) | wc -l)"; \
		echo -e "- Total size: $$(du -sh $(BUILD_DIR) | cut -f1)"; \
		echo -e ""; \
		echo -e "Validation Status:"; \
		if $(MAKE) validate-xhtml >/dev/null 2>&1; then \
			echo -e "- XHTML Validation: PASS"; \
		else \
			echo -e "- XHTML Validation: FAIL"; \
		fi; \
		if $(MAKE) validate-structure >/dev/null 2>&1; then \
			echo -e "- Structure Validation: PASS"; \
		else \
			echo -e "- Structure Validation: FAIL"; \
		fi; \
		if $(MAKE) validate-links >/dev/null 2>&1; then \
			echo -e "- Link Validation: PASS"; \
		else \
			echo -e "- Link Validation: FAIL"; \
		fi; \
		echo -e ""; \
		echo -e "File List:"; \
		$(FIND) $(BUILD_DIR) -type f | sort; \
	} > "$$report_file"; \
	echo -e "$(GREEN)✓ Report generated: $$report_file$(NC)"

# =============================================================================
# Development Targets
# =============================================================================

## Start development server
serve:
	@echo -e "$(BLUE)🚀 Starting development server...$(NC)"
	@$(ZOLA) serve

## Show build information
info:
	@echo -e "$(BLUE)ℹ️  Build Information$(NC)"
	@echo -e "======================"
	@echo -e "Project: $(SITE_NAME)"
	@echo -e "Build Date: $(BUILD_DATE)"
	@echo -e "Version: $(BUILD_VERSION)"
	@echo -e "Git Hash: $(BUILD_HASH)"
	@echo -e "Build Dir: $(BUILD_DIR)"
	@echo -e "Zola: $(ZOLA)"
	@echo -e "XMLLint: $(XMLLINT)"
	@echo -e "Environment: $$(if [ "$$CI" = "true" ]; then echo -e "CI/CD"; else echo -e "Local"; fi)"

# =============================================================================
# Cleanup Targets
# =============================================================================

## Clean build artifacts
clean:
	@echo -e "$(BLUE)🧹 Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -rf $(TEMP_DIR)
	@echo -e "$(GREEN)✓ Build artifacts cleaned$(NC)"

## Clean all generated files
clean-all: clean
	@echo -e "$(BLUE)🧹 Cleaning all generated files...$(NC)"
	@rm -rf $(REPORTS_DIR)
	@rm -f $(TEMPLATES_DIR)/year.html
	@echo -e "$(GREEN)✓ All generated files cleaned$(NC)"

# =============================================================================
# CI/CD Integration Targets
# =============================================================================

## CI/CD pipeline target
ci: check-deps
	@echo -e "$(BLUE)🤖 Running CI/CD pipeline...$(NC)"
	@$(MAKE) clean
	@$(MAKE) all
	@$(MAKE) test
	@$(MAKE) generate-report
	@echo -e "$(GREEN)✓ CI/CD pipeline completed successfully$(NC)"

## Quick validation (for git hooks)
quick-check:
	@echo -e "$(BLUE)⚡ Running quick validation...$(NC)"
	@if [ -d "$(BUILD_DIR)" ]; then \
		$(MAKE) validate-structure; \
	else \
		echo -e "$(YELLOW)⚠️  No build directory found, skipping validation$(NC)"; \
	fi

# =============================================================================
# Archive and Deployment Helpers
# =============================================================================

## Create deployment archive
archive: all
	@echo -e "$(BLUE)📦 Creating deployment archive...$(NC)"
	@archive_name="$(SITE_NAME)-$(BUILD_VERSION)-$$(date +%Y%m%d-%H%M%S).tar.gz"; \
	tar -czf "$$archive_name" -C $(BUILD_DIR) .; \
	echo -e "$(GREEN)✓ Archive created: $$archive_name$(NC)"

## Verify deployment readiness
verify-deployment: all
	@echo -e "$(BLUE)🔍 Verifying deployment readiness...$(NC)"
	@checklist=0; \
	if [ -f "$(BUILD_DIR)/index.xhtml" ]; then \
		echo -e "  ✓ Homepage exists"; \
	else \
		echo -e "  $(RED)✗ Homepage missing$(NC)"; checklist=1; \
	fi; \
	if [ -f "$(BUILD_DIR)/main.css" ]; then \
		echo -e "  ✓ Stylesheet exists"; \
	else \
		echo -e "  $(RED)✗ Stylesheet missing$(NC)"; checklist=1; \
	fi; \
	if [ $$checklist -eq 0 ]; then \
		echo -e "$(GREEN)✓ Site ready for deployment$(NC)"; \
	else \
		echo -e "$(RED)✗ Site not ready for deployment$(NC)"; exit 1; \
	fi

# Ensure directories exist
$(BUILD_DIR) $(REPORTS_DIR) $(TEMP_DIR):
	@mkdir -p $@

# Help with target descriptions
.PHONY: help
%:
	@grep -E '^## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = "## "}; {printf "  %-15s %s\n", $$1, $$2}'
