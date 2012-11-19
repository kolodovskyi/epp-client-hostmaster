# Hostmaster.UA EPP (Extensible Provisioning Protocol) client library

EPP client library based on [epp-client-base](https://rubygems.org/gems/epp-client-base) gem.
Full specification see at [Hostmaster.UA EPP Project](https://epp.hostmaster.ua).

## Installation

Add this line to your application's Gemfile:

    gem 'epp-client-hostmaster'

or this line:

    gem 'epp-client-hostmaster', git: 'https://github.com/kolodovskyy/epp-client-hostmaster.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install epp-client-hostmaster

## Usage (example)

    require "epp-client/hostmaster"

    #ENV['EPP_CLIENT_DEBUG'] = 'yes'

    c = EPPClient::Hostmaster.new(
      client_id: 'LOGIN',
      password: 'PASSWORD',
      ssl_cert: 'epp.crt',
      ssl_key: 'epp.key'
    )

    begin
      c.open_connection
      c.login
      c.hello

      c.contact_check 'test1', 'test2'
      puts c.contact_info 'test1'

      c.contact_create(
        id: 'test2',
        postalInfo: {
          loc: {
            name: 'Test name',
            org: 'Test organization',
            addr: {
              street: [ 'Test street' ],
              city: 'Kiev',
              pc: '00000',
              cc: 'UA'
            }
          }
        },
        voice: '+380.441234567',
        fax: '+380.441234567',
        email: 'test@test.com',
        authInfo: 'testpassword'
      )

      c.contact_update(
        id: 'test',
        chg: {
          fax: '+380.447654321'
        }
      )

      c.contact_delete 'test2'

      c.host_check 'ns1.test.epp.ua', 'ns2.test.epp.ua'
      c.host_info 'ns1.test.epp.ua'
      c.host_create name: 'ns2.test.epp.ua', addrv4: [ '8.8.8.8' ]
      c.host_update(
        name: 'ns2.test.epp.ua',
        rem: {
          addrv4: '8.8.8.8'
        },
        add: {
          addrv4: '8.8.8.8'
        }
      )
      c.host_delete 'ns2.test.epp.ua'

      puts c.domain_check 'test1.epp.ua', 'test2.epp.ua'
      puts c.domain_info 'test1.epp.ua'
      c.domain_create(
        name: 'test3.epp.ua',
        period: {
          unit: 'y',
          number: '1'
        },
        ns: [ 'ns1.test.epp.ua' ],
        registrant: 'test',
        contacts: {
          admin: [ 'test' ],
          tech: [ 'test' ]
        }
      )

      puts c.domain_renew(
        name: 'test.epp.ua',
        curExpDate: '2013-11-19',
        period: {
          unit: 'y',
          number: '1'
        }
      )

      c.domain_delete('test.epp.ua')
      c.domain_restore('test.epp.ua')

      c.domain_update(
        name: 'test.epp.ua',
        chg: {
          registrant: 'test1'
        }
      )

      puts c.poll_req
      puts c.poll_ack

      puts c.transfer_request name: 'test-transfer.epp.ua', authInfo: '111'
      puts c.transfer_cancel 'test-transfer.epp.ua'
      puts c.transfer_query 'test-transfer.epp.ua'

      c.logout
    rescue => error
      puts error.to_s
      puts error.backtrace
    ensure
      c.close_connection
    end

## Maintainers and Authors

Yuriy Kolodovskyy (https://github.com/kolodovskyy)

## License

MIT License. Copyright 2012 [Yuriy Kolodovskyy](http://twitter.com/kolodovskyy)
