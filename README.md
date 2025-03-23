# Switchbox

## Overview

Switchbox is a Ruby-based application designed to control smart devices such as SwitchBot. It provides a simple and efficient way to interact with IoT devices using environment variables for configuration.

## Features

- Control SwitchBot devices via API
- Manage settings using environment variables
- Easily customizable with Ruby

## Requirements

- Ruby 3.4.0
- Gems listed in the `Gemfile`

## Installation

1. Clone the repository:

   ```bash
   git clone <repository_url>
   cd switchbox
   ```

2. Install the required gems:

   ```bash
   bundle install
   ```

3. Set up environment variables. Create a .env file in the root directory and add the following:

   ```
   SWITCHBOT_TOKEN=your_switchbot_token
   SWITCHBOT_SECRET=your_switchbot_secret
   ```

## Usage

1. Run the application:

   ```
   ruby bin/switchbox.rb
   ```

2. Use the provided commands to control your devices.
3. Logs and error messages will be displayed in the console.

## Note

- This application uses the SwitchBot API. You need to obtain an API token and secret from the official SwitchBot website.
- Keep your .env file secure as it contains sensitive information.

