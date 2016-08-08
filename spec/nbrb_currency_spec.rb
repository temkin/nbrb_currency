require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'yaml'

describe 'NbrbCurrency' do
  before(:each) do
    @bank = NbrbCurrency.new
    @cache_path = File.expand_path(File.dirname(__FILE__) + '/exchange_rates.xml')
    @yml_cache_path = File.expand_path(File.dirname(__FILE__) + '/exchange_rates.yml')
    @tmp_cache_path = File.expand_path(File.dirname(__FILE__) + '/tmp/exchange_rates.xml')
    @exchange_rates = YAML.load_file(@yml_cache_path)
  end

  after(:each) do
    File.delete @tmp_cache_path if File.exist? @tmp_cache_path
  end

  it 'should save the xml file from nbrb given a file path' do
    @bank.save_rates(@tmp_cache_path)
    expect(File.exist?(@tmp_cache_path)).to be_truthy
  end

  it 'should raise an error if an invalid path is given to save_rates' do
    expect { @bank.save_rates(nil) }.to raise_exception
  end

  it 'should update itself with exchange rates from nbrb website' do
    allow(OpenURI::OpenRead).to receive(:open).with(NbrbCurrency::NBRB_RATES_URL).and_return(@cache_path)
    @bank.update_rates
    NbrbCurrency::CURRENCIES.reject { |c| %w(LVL LTL).include?(c) }.each do |currency|
      expect(@bank.get_rate(currency, 'BYN').to_f).to be > 0
    end
  end

  it 'should update itself with exchange rates from cache' do
    @bank.update_rates(@cache_path)
    NbrbCurrency::CURRENCIES.reject { |c| %w(LVL).include?(c) }.each do |currency|
      expect(@bank.get_rate(currency, 'BYN')).to be > 0
    end
  end

  it 'should return the correct exchange rates using exchange' do
    @bank.update_rates(@cache_path)
    NbrbCurrency::CURRENCIES.reject { |c| %w(JPY KWD IRR ISK).include?(c) }.each do |currency|
      expect(@bank.exchange(100, currency, 'BYN').cents).to eql((@exchange_rates['currencies'][currency].to_f * 100).round)
    end
    subunit = Money::Currency.wrap('KWD').subunit_to_unit.to_f
    expect(@bank.exchange(1000, 'KWD', 'BYN').cents).to eql ((subunit / 1000) * @exchange_rates['currencies']['KWD'].to_f * 100).round
    subunit = Money::Currency.wrap('JPY').subunit_to_unit.to_f
    expect(@bank.exchange(100, 'JPY', 'BYN').cents).to eql(((subunit * 100) * @exchange_rates['currencies']['JPY'].to_f * 100).round)
  end

  it 'should return the correct exchange rates using exchange_with' do
    @bank.update_rates(@cache_path)
    NbrbCurrency::CURRENCIES.reject { |c| %w(JPY KWD IRR ISK).include?(c) }.each do |currency|
      expect(@bank.exchange_with(Money.new(100, currency), 'BYN').cents).to eql((@exchange_rates['currencies'][currency].to_f * 100).round)
      expect(@bank.exchange_with(1.to_money(currency), 'BYN').cents).to eql((@exchange_rates['currencies'][currency].to_f * 100).round)
    end
    expect(@bank.exchange_with(5000.to_money('JPY'), 'BYN').cents).to eql(55_971_500)
  end

  # in response to #4
  it 'should exchange btc' do
    Money::Currency.table[:btc] = {
      priority: 1,
      iso_code: 'BTC',
      name: 'Bitcoin',
      symbol: 'BTC',
      subunit: 'Cent',
      subunit_to_unit: 1000,
      separator: '.',
      delimiter: ','
    }
    @bank.add_rate('USD', 'BTC', 1 / 13.7603)
    @bank.add_rate('BTC', 'USD', 13.7603)
    expect(@bank.exchange(100, 'BTC', 'USD').cents).to be 138
  end
end
