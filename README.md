# retry plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-retry)

A fastlane plugin that automatically retries failed XCUITest test cases. This plugin is loosely based off [lyndsey-ferguson's fastlane-plugin-test_center](https://github.com/lyndsey-ferguson/fastlane-plugin-test_center) plugin, which uses JUnit reports instead of PList to generate a simple HTML report.

This plugin works with the following logic:
1) Run the whole test suite once
2) Parse the generated .plist results to obtain a list of the failed tests
3) Retry the failed tests an 'x' number of times (see below for how to specify the number of retries) and generate a .plist report for each retry run
4) Merge all .plist reports together to generate one final .plist report

Tip: You can then use the final .plist report with the [XCHtmlReport plugin](https://github.com/TitouanVanBelle/XCTestHTMLReport) to generate a very beautiful HTML report including screenshots and console logs! See the sample fastfile for usage.

This plugin is available in the [Ruby Gems directory](https://rubygems.org/gems/fastlane-plugin-retry).

## Installation

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-retry`, add it to your project by running:

```
fastlane add_plugin retry
```
Check that the command above generated a Pluginfile in your project's fastlane folder. The Pluginfile should contain the following text:
```
gem 'fastlane-plugin-retry', '~> 1.0', '>= 1.0.5'
```
Add the following line to your project's Gemfile:
```
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```
Finally, run the following command to install the plugin files to your project's Bundler folder.
```
bundle install
```

## Usage

See the sample fastfile for how to configure your project's fastfile. Once you have configured your fastfile, use the following command to run your tests with retry (you can change the number of tries and the device).
```
bundle exec fastlane run_tests_with_retry tries:3 devices:"platform=iOS Simulator,name=iPhone 8,OS=11.4"
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
