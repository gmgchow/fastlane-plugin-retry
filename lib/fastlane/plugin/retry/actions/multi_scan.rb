module Fastlane
  module Actions
    require 'fastlane/actions/scan'
    require 'shellwords'
    require 'nokogiri'
    require 'nokogiri-plist'

    class MultiScanAction < Action
      def self.run(params)
        try_count = 0
        scan_options = params.values.reject { |k| k == :try_count }
        final_report_path = scan_options[:result_bundle]
        unless Helper.test?
          FastlaneCore::PrintTable.print_values(
            config: params._values.reject { |k, v| scan_options.key?(k) },
            title: "Summary for multi_scan"
          )
        end

        begin
          try_count += 1
          scan_options = config_with_retry(scan_options, try_count)
          config = FastlaneCore::Configuration.create(Fastlane::Actions::ScanAction.available_options, scan_options)
          Fastlane::Actions::ScanAction.run(config)
        rescue FastlaneCore::Interface::FastlaneTestFailure => e
          UI.verbose("Scan failed with #{e}")
          if try_count < params[:try_count]
            report_filepath = plist_report_filepath(scan_options)
            failed_tests = parse_failures(report_filepath, params[:scheme])
            scan_options[:only_testing] = failed_tests
            retry
          end
        end
        merge_reports(scan_options, final_report_path)
      end

      # Parse the names of the failed test cases
      def self.parse_failures(plist, scheme_name)
        failures = Array.new
        target_report = File.open(plist) {|f| Nokogiri::XML(f)}
        # Get the names of all the failed tests from the specified report
        failed = target_report.xpath("//key[contains(.,'Failure')]/../key[contains(.,'TestIdentifier')]/following-sibling::string[contains(.,'()') and contains (., '/')]")
        failed.each do |test_name|
          # Reformat the test name to be usable by the xcodebuild 'only_testing' flag
          failures << ("#{scheme_name}/" + test_name.to_s.split('(')[0].split('>')[1])
        end
        failures
      end

      # Merge results from all retries
      def self.merge_reports(scan_options, final_report_path)
        folder = get_folder_root(scan_options[:output_directory])
        report_files = Dir.glob("#{folder}*/*/*/action_TestSummaries.plist")
        asset_files = Dir.glob("#{folder}*/*/*/Attachments")
        log_files = Dir.glob("#{folder}*/*/*/action.xcactivitylog")
        if report_files.size > 1
          other_action.collate_junit_reports(
            reports: report_files,
            collated_report: final_report_path,
            assets: asset_files,
            logs: log_files,
          )
        end
      end

      # Create scan config
      def self.config_with_retry(config, count)
        folder = get_folder_root(config[:result_bundle])
        config[:result_bundle] = (folder + count.to_s)
        config[:output_directory] = (folder + count.to_s)
        config
      end

      # Get folder location
      def self.get_folder_root(folder)
        folder = folder.gsub(/ *\d+$/, '')
        folder
      end

      def self.plist_report_filepath(config)
        File.absolute_path(File.join(config[:output_directory], "/#{config[:scheme]}.test_result/TestSummaries.plist"))
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Uses scan to run Xcode tests a given number of times: only re-testing failing tests."
      end

      def self.details
        "Use this action to run your tests if you have fragile tests that fail sporadically."
      end

      def self.scan_options
        ScanAction.available_options
      end

      def self.available_options
        scan_options + [
          FastlaneCore::ConfigItem.new(
            key: :try_count,
            env_name: "FL_MULTI_SCAN_TRY_COUNT",
            description: "The number of times to retry running tests via scan",
            type: Integer,
            is_string: false,
            default_value: 1
          )
        ]
      end

      def self.authors
        ["Gloria Chow/@gmgchow"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
