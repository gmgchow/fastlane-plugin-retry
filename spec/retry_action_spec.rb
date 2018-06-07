describe Fastlane::Actions::RetryAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The retry plugin is working!")

      Fastlane::Actions::RetryAction.run(nil)
    end
  end
end
