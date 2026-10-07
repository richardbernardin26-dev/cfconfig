/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* BL-1711: .cfconfig mail settings must map to/from modules.mail.settings
*/
component extends="tests.BaseTest" appMapping="/tests" {

	function run(){

		describe( "BoxLang 1 Server config", function(){

			it( "can read config", function() {
				var boxlangConfig = getInstance( 'BoxLang1@cfconfig-services' )
					.read( expandPath( '/tests/resources/boxlang1/boxlang.json' ) );

				expect( boxlangConfig.getMemento() ).toBeStruct();
			});

			it( "reads modules.mail.settings into CFConfig mail keys", function() {
				var boxlangConfig = getInstance( 'BoxLang1@cfconfig-services' )
					.read( expandPath( '/tests/resources/boxlang1/boxlang.json' ) );

				expect( boxlangConfig.getMailDefaultEncoding() ).toBe( 'UTF-8' );
				expect( boxlangConfig.getMailSpoolEnable() ).toBeTrue();
				expect( boxlangConfig.getMailSpoolInterval() ).toBe( 30 );
				expect( boxlangConfig.getMailConnectionTimeout() ).toBe( 60 );
			});

			it( "writes CFConfig mail keys into modules.mail.settings", function() {
				var outFile = expandPath( '/tests/resources/tmp/boxlang-mail.json' );
				if( fileExists( outFile ) ) { fileDelete( outFile ); }

				getInstance( 'BoxLang1@cfconfig-services' )
					.setMailSpoolEnable( true )
					.setMailSpoolInterval( 45 )
					.setMailConnectionTimeout( 90 )
					.setMailDefaultEncoding( 'UTF-8' )
					.write( outFile );

				expect( fileExists( outFile ) ).toBeTrue();
				var written = deserializeJSON( fileRead( outFile ) );

				expect( written ).toHaveKey( 'modules' );
				expect( written.modules ).toHaveKey( 'mail' );
				expect( written.modules.mail.settings.spoolEnable ).toBeTrue();
				expect( written.modules.mail.settings.spoolInterval ).toBe( 45 );
				expect( written.modules.mail.settings.connectionTimeout ).toBe( 90 );
				expect( written.modules.mail.settings.defaultEncoding ).toBe( 'UTF-8' );

				// CFConfig-style keys should not be left at the top level
				expect( written ).notToHaveKey( 'mailSpoolEnable' );
				expect( written ).notToHaveKey( 'mailSpoolInterval' );
			});

			it( "round-trips mail settings without losing data", function() {
				var outFile = expandPath( '/tests/resources/tmp/boxlang-roundtrip.json' );
				if( fileExists( outFile ) ) { fileDelete( outFile ); }

				getInstance( 'BoxLang1@cfconfig-services' )
					.read( expandPath( '/tests/resources/boxlang1/boxlang.json' ) )
					.write( outFile );

				var reread = getInstance( 'BoxLang1@cfconfig-services' )
					.read( outFile );

				expect( reread.getMailSpoolEnable() ).toBeTrue();
				expect( reread.getMailSpoolInterval() ).toBe( 30 );
				expect( reread.getMailConnectionTimeout() ).toBe( 60 );
				expect( reread.getMailDefaultEncoding() ).toBe( 'UTF-8' );
			});

			it( "does not error when the config has no mail module settings", function() {
				var boxlangConfig = getInstance( 'BoxLang1@cfconfig-services' )
					.read( expandPath( '/tests/resources/boxlang1/boxlang-nomail.json' ) );

				expect( boxlangConfig.getMemento() ).toBeStruct();
			});

			it( "preserves other module settings when writing mail settings", function() {
				var outFile = expandPath( '/tests/resources/tmp/boxlang-preserve.json' );
				if( fileExists( outFile ) ) { fileDelete( outFile ); }

				getInstance( 'BoxLang1@cfconfig-services' )
					.read( expandPath( '/tests/resources/boxlang1/boxlang.json' ) )
					.setMailSpoolInterval( 99 )
					.write( outFile );

				var written = deserializeJSON( fileRead( outFile ) );
				expect( written.modules ).toHaveKey( 'compat-cfml' );
				expect( written.modules.mail.settings.spoolInterval ).toBe( 99 );
			});

		});

	}

}
