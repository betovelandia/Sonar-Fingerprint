%% Analyze 
 
%	This Routine takes all the radio stations recorded and the ads
% 	and obtains the ocurrences of each add on all the records

% 1. Obtain all the radio stations tracks and create the reference database, here a local URL can be provided or an http addres would be ok too
% ex. tks= myls(['http://labrosa.ee.columbia.edu/~dpwe/tmp/Nine_Lives/*.mp3']);
%	Is necesary that all the radio station tracks have the following date structure in the name
%   								'XXXX yyyy-mm-dd HH-MM-SS'
%	Where XXXX =  Short name for the station corresponding to the value inserted in the db table Stations.


% tks= myls(['/Users/albertovelandia/Music/Recordings/*.mp3']);

% 2. % Initialize the hash table database array 

% clear_hashtable

% 3. Calculate the landmark hashes for each reference track and store
%    it in the array, time depends on the Computers CPU and the encoding of the MP3, in Sonar the specs are:
%		Sample Rate : 11050 Hz
%		Bitrate : 16 Kbps
% 		Channels : Mono
%		MP3 - Constant Bitrate

% add_tracks(tks);


% 4. Connect to the MySQL Database

mysql('close');
db = mysql( 'open', 'localhost', 'root', '' );
db = mysql('use sonar');

% 5. Obtain the list of all the ads that will be matched against the database

ads = myls(['/Users/albertovelandia/Music/Ads/*.mp3']); % Obtain the cell array of strings containing the files on the ads directory
nads = length(ads);

for i = 1:nads						    % For each ad on the folder
	[dt,srt] = mp3read(char(ads(1,i))); % Read the file and
	R = match_query(dt,srt);    	    % Run the query
	[nmatches,columnas]=size(R);
	
	for j= 1:nmatches				    									     % For every AD we need to find
		url = tks( 1, R(j,1) );												     % The URL of the file
		date = strrep(url, '.mp3', ''); 									     % Removing the extension of the string
		date = strrep(date, '/Users/albertovelandia/Music/Recordings/', '');     % Removing the file location out of the equation
		date = char(date);
		mysql_station = date(1:4);											     % We extract the short name of the radio Station
		date = strrep(date, 'CARA ', '');										 % And obtaining the time of the start of the recording
		queryString = sprintf('SELECT id FROM Stations WHERE short_name = "%d"', mysql_station);			 								     
		mysql_station_id = mysql(QueryString); % With the short name of the radio station we locate its id.
		disp(mysql_station_id);
		startR = datevec(date, 'YYYY-MM-DD HH-mm-SS'); 						     % Converting the date string in to a variable that can be handled by matlab as a date
		startA = addtodate(datenum(startR), round(R(i,3)*0.032), 'second' );     % Adding the delay found by the algorithm in steps of 32 ms
		mysql_time = datestr( startA , 'YYYY-MM-DD HH:mm:SS' );				     % Converting that into a format that can be saved as a datetime variable in MySQL
		mysql_landmarks = R(j,2);											     % Obtaining the number of landmarks that the algorithm found
		mysql_ad_id = strrep( char(ads(1,i)) , '.mp3', '');					     % Extracting the id of the ad we are processing
		mysql_ad_id = strrep( mysql_ad_id, '/Users/albertovelandia/Music/Ads/', ''); % Cleaning the garbage out of the string and getting just the id

		
		% After getting the information for each report we proceed to insert it on the da
		% mysql(' INSERT INTO Reports (created, time, landmarks, ad_id, station_id ) VALUES ( NOW() , "%03d", "%03d", "%03d", "%03d")' , mysql_time, mysql_landmarks, mysql_ad_id, mysql_station_id);
		
		
	end
	
end
