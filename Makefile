BUILD_DIR := public

.PHONY: all clean build convert

all: clean build convert

clean:
	rm -rf $(BUILD_DIR)

build:
	zola build

convert:
	find $(BUILD_DIR) -name "*.html" -exec sh -c 'mv "$$1" "$${1%.html}.xhtml"' _ {} \;
	find $(BUILD_DIR) -type f \( -name "*.xhtml" -o -name "*.xml" \) -exec sed -i 's/\.html"/.xhtml"/g; s/\.html#/.xhtml#/g' {} +
