# Defines a target named $(my_target) for generating a coverage report.

my_report_dir := $(my_coverage_dir)/reports
my_coverage_output := $(my_report_dir)/coverage.xml

# Private variables.
$(my_coverage_output): PRIVATE_MODULE := $(LOCAL_MODULE)
$(my_coverage_output): PRIVATE_COVERAGE_FILE := $(my_coverage_file)
$(my_coverage_output): PRIVATE_COVERAGE_SRCS_JARS := $(my_coverage_srcs_jars)
ifdef my_instrument_srcjars
  $(my_coverage_output): PRIVATE_SRC_ARGS := --srcjars $(call normalize-path-list,$(my_instrument_srcjars))
  $(my_coverage_output): $(my_instrument_srcjars)
else
  $(my_coverage_output): PRIVATE_SRC_ARGS := --srcs $(call normalize-path-list,$(my_instrument_source_dirs))
endif
$(my_coverage_output): PRIVATE_COVERAGE_REPORT_CLASS := $(my_coverage_report_class)
$(my_coverage_output): PRIVATE_COVERAGE_REPORT_JAR := $(my_coverage_report_jar)
$(my_coverage_output): PRIVATE_REPORT_DIR := $(my_report_dir)

# Generate the coverage report.
# Touches the output file and continues on failure to avoid breaking the build when a test fails to
# generate coverage data.
$(my_coverage_output): $(my_collect_file) $(my_coverage_report_jar)
	$(hide) rm -f $@
	$(hide) rm -rf $(PRIVATE_REPORT_DIR)
	$(hide) mkdir -p $(PRIVATE_REPORT_DIR)
	$(hide) $(JAVA) \
			-cp $(PRIVATE_COVERAGE_REPORT_JAR) \
			$(PRIVATE_COVERAGE_REPORT_CLASS) \
			-classpath $(strip $(call normalize-path-list, $(PRIVATE_COVERAGE_SRCS_JARS))) \
			--exec-file $(PRIVATE_COVERAGE_FILE) \
			--name $(PRIVATE_MODULE) \
			--report-dir $(PRIVATE_REPORT_DIR)/ \
			$(PRIVATE_SRC_ARGS) \
			>$(PRIVATE_REPORT_DIR)/reporter.txt 2>&1 \
		|| touch $@
	@echo "Coverage report: file://"$(realpath $(PRIVATE_REPORT_DIR))"/index.html"


# Generate a ZIP file of the coverage report.
my_coverage_output_zip := $(my_coverage_dir)/report-html.zip

$(my_coverage_output_zip): PRIVATE_REPORT_DIR := $(my_report_dir)
$(my_coverage_output_zip): $(my_coverage_output)
	$(hide) cd $(PRIVATE_REPORT_DIR) && zip --quiet -r $(PWD)/$@ .

# Add coverage report zip to dist files.
$(call dist-for-goals, $(my_report_target), \
    $(my_coverage_output_zip):robotests-coverage/$(LOCAL_MODULE)/robolectric-html-coverage.zip \
    $(my_coverage_output):robotests-coverage/$(LOCAL_MODULE)/robolectric-coverage.xml)

ALL_TARGETS.$(my_coverage_output_zip).META_LIC:=$(module_license_metadata)
ALL_TARGETS.$(my_coverage_output).META_LIC:=$(module_license_metadata)

# Running the coverage will always generate the report.
$(my_target): $(my_coverage_output)

# Reset local variables.
my_coverage_output :=
my_coverage_output_zip :=
my_report_dir :=
