#require 'pry'
require 'rubygems'
require 'rspec'
require 'rspec/autorun'
require 'rails'
require 'active_record'
require 'action_controller'

module Rails
  class <<self
    def root
      File.expand_path(__FILE__).split('/')[0..-3].join('/')
    end
  end
end

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'bullet'
Bullet.enable = true
ActiveRecord::Migration.verbose = false

MODELS = File.join(File.dirname(__FILE__), "models")
$LOAD_PATH.unshift(MODELS)

# Autoload every model for the test suite that sits in spec/models.
Dir[ File.join(MODELS, "*.rb") ].sort.each do |file|
  name = File.basename(file, ".rb")
  autoload name.camelize.to_sym, name
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :categories do |t|
      t.column :name, :string
    end

    create_table :posts do |t|
      t.column :name, :string
      t.column :category_id, :integer
      t.column :writer_id, :integer
    end

    create_table :comments do |t|
      t.column :name, :string
      t.column :post_id, :integer
      t.column :author_id, :integer
    end

    create_table :entries do |t|
      t.column :name, :string
      t.column :category_id, :integer
    end

    create_table :base_users do |t|
      t.column :name, :string
      t.column :type, :string
      t.column :newspaper_id, :integer
    end

    create_table :newspapers do |t|
      t.column :name, :string
    end

    create_table :countries do |t|
      t.string :name
    end

    create_table :cities do |t|
      t.string :name
      t.integer :country_id
    end

    create_table :people do |t|
      t.string :name
      t.integer :pets_count
    end

    create_table :pets do |t|
      t.string :name
      t.integer :person_id
    end

    create_table :students do |t|
      t.column :name, :string
    end

    create_table :teachers do |t|
      t.column :name, :string
    end

    create_table :students_teachers, :id => false do |t|
      t.column :student_id, :integer
      t.column :teacher_id, :integer
    end

    create_table :firms do |t|
      t.column :name, :string
    end

    create_table :clients do |t|
      t.column :name, :string
    end

    create_table :relationships do |t|
      t.column :firm_id, :integer
      t.column :client_id, :integer
    end

    create_table :companies do |t|
      t.column :name, :string
    end

    create_table :addresses do |t|
      t.column :name, :string
      t.column :company_id, :integer
    end

    create_table :contacts do |t|
      t.column :name, :string
    end

    create_table :emails do |t|
      t.column :name, :string
      t.column :contact_id, :integer
    end

    create_table :documents do |t|
      t.string :name
      t.string :type
      t.integer :parent_id
      t.integer :author_id
    end

    create_table :authors do |t|
      t.string :name
    end

    create_table :submissions do |t|
      t.column :name, :string
      t.column :category_id, :integer
      t.column :user_id, :integer
    end

    create_table :users do |t|
      t.column :name, :string
      t.column :category_id, :integer
    end

    create_table :locations do |t|
      t.column :name, :string
    end

    create_table :hotels do |t|
      t.column :name, :string
      t.column :location_id, :integer
    end

    create_table :deals do |t|
      t.column :name, :string
      t.column :hotel_id, :integer
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')


RSpec.configure do |config|
  config.before(:all) do
    setup_db

    newspaper1 = Newspaper.create(:name => "First Newspaper")
    newspaper2 = Newspaper.create(:name => "Second Newspaper")

    writer1 = Writer.create(:name => 'first', :newspaper => newspaper1)
    writer2 = Writer.create(:name => 'second', :newspaper => newspaper2)
    user1 = BaseUser.create(:name => 'third', :newspaper => newspaper1)
    user2 = BaseUser.create(:name => 'fourth', :newspaper => newspaper2)


    category1 = Category.create(:name => 'first')
    category2 = Category.create(:name => 'second')

    post1 = category1.posts.create(:name => 'first', :writer => writer1)
    post1a = category1.posts.create(:name => 'like first', :writer => writer2)
    post2 = category2.posts.create(:name => 'second', :writer => writer2)

    comment1 = post1.comments.create(:name => 'first', :author => writer1)
    comment2 = post1.comments.create(:name => 'first2', :author => writer1)
    comment3 = post1.comments.create(:name => 'first3', :author => writer1)
    comment4 = post1.comments.create(:name => 'second', :author => writer2)
    comment8 = post1a.comments.create(:name => "like first 1", :author => writer1)
    comment9 = post1a.comments.create(:name => "like first 2", :author => writer2)
    comment5 = post2.comments.create(:name => 'third', :author => user1)
    comment6 = post2.comments.create(:name => 'fourth', :author => user2)
    comment7 = post2.comments.create(:name => 'fourth', :author => writer1)

    entry1 = category1.entries.create(:name => 'first')
    entry2 = category1.entries.create(:name => 'second')

    student1 = Student.create(:name => 'first')
    student2 = Student.create(:name => 'second')
    teacher1 = Teacher.create(:name => 'first')
    teacher2 = Teacher.create(:name => 'second')
    student1.teachers = [teacher1, teacher2]
    student2.teachers = [teacher1, teacher2]
    teacher1.students << student1
    teacher2.students << student2

    firm1 = Firm.create(:name => 'first')
    firm2 = Firm.create(:name => 'second')
    client1 = Client.create(:name => 'first')
    client2 = Client.create(:name => 'second')
    firm1.clients = [client1, client2]
    firm2.clients = [client1, client2]
    client1.firms << firm1
    client2.firms << firm2

    company1 = Company.create(:name => 'first')
    company2 = Company.create(:name => 'second')

    Address.create(:name => 'first', :company => company1)
    Address.create(:name => 'second', :company => company2)

    contact1 = Contact.create(:name => 'first')
    contact2 = Contact.create(:name => 'second')

    email1 = contact1.emails.create(:name => 'first')
    email2 = contact1.emails.create(:name => 'second')
    email3 = contact2.emails.create(:name => 'third')
    email4 = contact2.emails.create(:name => 'fourth')

    country1 = Country.create(:name => 'first')
    country2 = Country.create(:name => 'second')

    country1.cities.create(:name => 'first')
    country1.cities.create(:name => 'second')
    country2.cities.create(:name => 'third')
    country2.cities.create(:name => 'fourth')

    person1 = Person.create(:name => 'first')
    person2 = Person.create(:name => 'second')

    person1.pets.create(:name => 'first')
    person1.pets.create(:name => 'second')
    person2.pets.create(:name => 'third')
    person2.pets.create(:name => 'fourth')

    author1 = Author.create(:name => 'author1')
    author2 = Author.create(:name => 'author2')
    folder1 = Folder.create(:name => 'folder1', :author_id => author1.id)
    folder2 = Folder.create(:name => 'folder2', :author_id => author2.id)
    page1 = Page.create(:name => 'page1', :parent_id => folder1.id, :author_id => author1.id)
    page2 = Page.create(:name => 'page2', :parent_id => folder1.id, :author_id => author1.id)
    page3 = Page.create(:name => 'page3', :parent_id => folder2.id, :author_id => author2.id)
    page4 = Page.create(:name => 'page4', :parent_id => folder2.id, :author_id => author2.id)

    user1 = User.create(:name => 'user1', :category => category1)
    user2 = User.create(:name => 'user2', :category => category1)

    submission1 = category1.submissions.create(:name => "submission1", :user => user1)
    submission2 = category1.submissions.create(:name => "submission2", :user => user2)
    submission3 = category2.submissions.create(:name => "submission3", :user => user1)
    submission4 = category2.submissions.create(:name => "submission4", :user => user2)

    location1 = Location.create(:name => "location1")
    location2 = Location.create(:name => "location2")

    hotel1 = location1.hotels.create(:name => "hotel1")
    hotel2 = location1.hotels.create(:name => "hotel2")
    hotel3 = location2.hotels.create(:name => "hotel3")
    hotel4 = location2.hotels.create(:name => "hotel4")

    deal1 = hotel1.deals.create(:name => "deal1")
    deal2 = hotel2.deals.create(:name => "deal2")
    deal3 = hotel3.deals.create(:name => "deal3")
    deal4 = hotel4.deals.create(:name => "deal4")
  end

  config.after(:all) do
    teardown_db
  end

  config.before(:each) do
    Bullet.start_request
  end

  config.after(:each) do
    Bullet.end_request
  end

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

module Bullet
  def self.collected_notifications_of_class( notification_class )
    Bullet.notification_collector.collection.select do |notification|
      notification.is_a? notification_class
    end
  end

  def self.collected_counter_cache_notifications
    collected_notifications_of_class Bullet::Notification::CounterCache
  end

  def self.collected_n_plus_one_query_notifications
    collected_notifications_of_class Bullet::Notification::NPlusOneQuery
  end

  def self.collected_unused_eager_association_notifications
    collected_notifications_of_class Bullet::Notification::UnusedEagerLoading
  end
end

module Bullet
  module Detector
    class Association
      class <<self
        # returns true if all associations are preloaded
        def completely_preloading_associations?
          Bullet.collected_n_plus_one_query_notifications.empty?
        end

        def has_unused_preload_associations?
          Bullet.collected_unused_eager_association_notifications.present?
        end

        # returns true if a given object has a specific association
        def creating_object_association_for?(object, association)
          object_associations[object].present? && object_associations[object].include?(association)
        end

        # returns true if a given class includes the specific unpreloaded association
        def detecting_unpreloaded_association_for?(klass, association)
          for_class_and_assoc = Bullet.collected_n_plus_one_query_notifications.select do |notification|
            notification.base_class == klass and
            notification.associations.include?( association )
          end
          for_class_and_assoc.present?
        end

        # returns true if the given class includes the specific unused preloaded association
        def unused_preload_associations_for?(klass, association)
          for_class_and_assoc = Bullet.collected_unused_eager_association_notifications.select do |notification|
            notification.base_class == klass and
            notification.associations.include?( association )
          end
          for_class_and_assoc.present?
        end
      end
    end
  end
end

class AppDouble
  def call env
    env = @env
    [ status, headers, response ]
  end

  def status= status
    @status = status
  end

  def headers= headers
    @headers = headers
  end

  def headers
    @headers ||= {}
    @headers
  end

  def response= response
    @response = response
  end

  private
  def status
    @status || 200
  end

  def response
    @response || ResponseDouble.new
  end
end

class ResponseDouble
  def initialize actual_body = nil
    @actual_body = actual_body
  end

  def body
    @body ||= "Hello world!"
  end

  def body= body
    @body = body
  end

  def each
    yield body
  end

  def close
  end
end
