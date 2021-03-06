require "geocoder/models/mongoid"

class Conferences::Event

  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :name
  field :summary
  field :location
  field :url
  field :start_date,  :type => Date
  field :end_date,    :type => Date
  field :coordinates, :type => Array
  field :address
  field :city
  field :state
  field :country

  reverse_geocoded_by :coordinates do |obj, results|
    if geo = results.first
      obj.city    = geo.city
      obj.state   = geo.state
      obj.country = geo.country
    end
  end

  before_create :reverse_geocode

  has_many :proposals
  has_and_belongs_to_many :searches, :class_name => "Conferences::Search"

  def self.future
    where(:start_date.gte => Date.today)# + 1.month)
  end

  def self.sorted
    asc(:start_date)
  end

  def self.from(ics)
    return [] unless ics
    IcsParser.entries_from(ics).inject([]){ |a, entry| a << find_or_create(IcsParser.new(entry).parse!)}
  end

  def self.find_or_create(entry)
    where(:name => entry[:name]).first || create(entry)
  end

  def self.upcoming
    where(:start_date.gt => Date.today.end_of_day)
  end

  def self.todo
    upcoming.select{|conf| conf.proposals.empty? }
  end

  def end_date
    self[:end_date] || self.start_date || Date.today
  end

  def sanitized_location
    [self.city, self.state, self.country].compact.join(', ')
  end

  def sanitized_summary
    self.summary.split("\\n")[0].gsub('\\','')
  end

  def tags
    [self.country, self.start_date.year.to_s].compact
  end

end
