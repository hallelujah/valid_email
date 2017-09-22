require 'spec_helper'

describe Message do
  context 'message is string' do
    subject { Message.new 'custom error' }
    it 'responds with the message' do
      expect(subject.result).to eq('custom error')
    end
  end

  context 'message is a proc object' do
    subject { Message.new proc { 'proc custom error' } }
    it 'responds with the message' do
      expect(subject.result).to eq('proc custom error')
    end
  end

  context 'message is a proc object' do
    subject { Message.new Proc.new { 'proc custom error' } }
    it 'responds with the message' do
      expect(subject.result).to eq('proc custom error')
    end
  end

  context 'message is a proc object' do
    subject { Message.new -> { 'proc custom error' } }
    it 'responds with the message' do
      expect(subject.result).to eq('proc custom error')
    end
  end
end
