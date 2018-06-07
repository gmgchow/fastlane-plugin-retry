require 'nokogiri'
require 'nokogiri-plist'
require 'FileUtils'

module Fastlane
  module Actions
    class CollateJunitReportsAction < Action

      def self.run(params)
        report_filepaths = params[:reports].reverse
        # If no retries are required return the results
        if report_filepaths.size == 1
          FileUtils.cp(report_filepaths[0], params[:collated_report])
        else
          target_report = File.open(report_filepaths.shift) {|f| Nokogiri::XML(f)}
          reports = report_filepaths.map { |report_filepath| Nokogiri::XML(Nokogiri::PList(open(report_filepath)).to_plist) }
          # Clean each retry report and merge it into the first report
          reports.each do |retry_report|
            retry_report = clean_report(retry_report.to_s)
            mergeLists(target_report, retry_report, params)
          end
        end
        # Merge screenshots and console logs from all retry runs
        merge_assets(params[:assets], params[:collated_report] + "/Attachments")
        merge_logs(params[:logs], params[:collated_report] + "/")
      end

      # Merges .plist reports
      def self.mergeLists(target_report, retry_report, params)
        UI.verbose("Merging retried results...")
        Dir.mkdir(params[:collated_report]) unless File.exists?(params[:collated_report])
        file_name = params[:collated_report] + "/action_TestSummaries.plist"
        retried_tests = retry_report.xpath("//key[contains(.,'TestSummaryGUID')]/..")
        current_node = retried_tests.shift
        while (current_node != nil)
          # For each retried test, get the corresponding node of data from the retried report and merge it into the base report
          testName = get_test_name(current_node)
          matching_node = target_report.at_xpath("//string[contains(.,'#{testName}')]/..")
          if (!matching_node.nil?)
            matching_node.previous.next.replace(current_node)
            write_report_to_file(target_report, file_name)
          end
          current_node = retried_tests.shift
        end
      end

      # Merges screenshots from all retries
      def self.merge_assets(asset_files, assets_folder)
        UI.verbose ("Merging screenshot folders...")
        Dir.mkdir(assets_folder) unless File.exists?(assets_folder)
        asset_files.each do |folder|
          FileUtils.cp_r(Dir[folder + '/*'], assets_folder)
        end
      end

      # Cleans formatting of report
      def self.clean_report(report)
        # Removes unescaped <> characters which cause the final .plist to become unreadable
        report = report.gsub("<XCAccessibilityElement:/>0x", " XCAccessibilityElement ")
        report = report.gsub("<XCAccessibilityElement:></XCAccessibilityElement:>", " XCAccessibilityElement ")
        report = Nokogiri::XML(report)
        report
      end

      # Merges console log of reports
      def self.merge_logs(log_files, logs_folder)
        UI.verbose("Merging console logs...")
        target_log = log_files.shift
        log_files.each do |log|
          to_append = File.read(log)
          File.open(target_log, "a") do |handle|
            handle.puts to_append
          end
          FileUtils.cp_r(target_log, logs_folder)
        end
      end

      # Outputs report to a new file
      def self.write_report_to_file(report, file_name)
        UI.verbose("Writing merged results to file...")
        File.new(file_name, 'w')
        File.open(file_name, 'w') do |f|
          f.write(report.to_xml)
        end
      end

      # Returns the test name of the retried test
      def self.get_test_name(test_data)
        test_name = test_data.xpath("(//key[contains(.,'TestSummaryGUID')])/../key[contains(.,'TestName')]/following-sibling::string").to_a[0].to_s
        test_name = test_name[8..-10]
        test_name
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Combines test results from multiple plist files."
      end

      def self.details
        "Based on the fastlane-plugins-test_center plugin by lyndsey-ferguson/@lyndseydf"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :reports,
            env_name: 'COLLATE_PLIST_REPORTS_REPORTS',
            description: 'An array of plist reports to collate. The first report is used as the base into which other reports are merged in',
            optional: false,
            type: Array,
            verify_block: proc do |reports|
              UI.user_error!('No plist report files found') if reports.empty?
              reports.each do |report|
                UI.user_error!("Error: plist report not found: '#{report}'") unless File.exist?(report)
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :collated_report,
            env_name: 'COLLATE_PLIST_REPORTS_COLLATED_REPORT',
            description: 'The final plist report file where all testcases will be merged into',
            optional: true,
            default_value: 'result.xml',
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :assets,
            env_name: 'COLLATE_PLIST_REPORTS_ASSETS',
            description: 'An array of plist reports to collate. The first report is used as the base into which other reports are merged in',
            optional: false,
            type: Array,
            verify_block: proc do |assets|
              UI.user_error!('No plist report files found') if assets.empty?
              assets.each do |asset|
                UI.user_error!("Error: plist report not found: '#{asset}'") unless File.exist?(asset)
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :logs,
            env_name: 'COLLATE_PLIST_REPORTS_LOGS',
            description: 'An array of plist reports to collate. The first report is used as the base into which other reports are merged in',
            optional: false,
            type: Array,
            verify_block: proc do |logs|
              UI.user_error!('No plist report files found') if logs.empty?
              logs.each do |log|
                UI.user_error!("Error: plist report not found: '#{log}'") unless File.exist?(log)
              end
            end
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
