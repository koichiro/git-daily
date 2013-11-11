require 'spec_helper'
require 'git-daily'

describe Git::Daily do
  context 'load commands' do
    subject { Git::Daily.application.load_commands }
    it 'load config' do
      p subject
      expect(subject).to include(/config/)
    end
  end
end
