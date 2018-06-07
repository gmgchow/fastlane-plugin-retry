# retry plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-retry)

Retries failed XCUITest test cases. 

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

See the sample fastfile for how to configure your project's fastfile. Once you have configured your fastfile, use the following command to run tests with retry.
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
