# Beer tap dispenser API

### Versions and dependencies:

The versions of Ruby and Rails used are Ruby 3.2.2 and Rails 7. The database used is the one recommended by the Ruby on Rails getting started guide, SQLite3.

### Configuration:

Once all the above dependencies are installed you can clone the repository 
```
git clone git@github.com:adrimll97/beer_tap_dispenser.git
```
Once inside the project, you need to install all the gem dependencies:
```
bundle install
```
To set up the database you just need to launch the project migrations:
```
bin/rails db:migrate
```
Once this is done, we would have the project installed and we could start the rails server to have the project running:
```
bin/rails s
```
With this we would have the project running and listening on port 3000.


### Structure and operation:

The project has the following tables:
```
Dispenser(id: integer, flow_volume: float, created_at: datetime, updated_at: datetime, price: float, status: integer)
DispenserUsage(id: integer, dispenser_id: integer, opened_at: datetime, closed_at: datetime, total_spend: float, created_at: datetime, updated_at: datetime, flow_volume: float, price: float)
```
The API has been developed following the documentations available at `https://rviewer.stoplight.io/docs/beer-tap-dispenser/9277750c26224-create-a-new-dispenser`.
To test the API you should use an application to make API calls, such as `Postman`, or directly with curl:
```
curl --request POST --url localhost:3000/api/v1/dispensers --header 'Content-Type: application/json' --data '{"flow_volume": 0.0653}'
```
```
curl --request PUT --url localhost:3000/api/v1/dispensers/1/status --header 'Content-Type: application/json' --data '{"status": "open", "updated_at": "2022-01-01T02:00:00Z"}'
curl --request PUT --url localhost:3000/api/v1/dispensers/1/status --header 'Content-Type: application/json' --data '{"status": "close", "updated_at": "2022-01-01T02:00:10Z"}'
```
```
curl --request GET --url localhost:3000/api/v1/dispensers/1/spending --header 'Content-Type: application/json'
```
