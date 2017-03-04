--Cards against humanity, faggotry edition
CAH = {}

CAH.BLACK_CARD = 0
CAH.WHITE_CARD = 1

if SERVER then

	CAH.EXPANSIONS = {
		BASE = "Base",
		PNS = "PENISCorp",
	}




	CAH.BLACK_CARDS = {}
	CAH.WHITE_CARDS = {}

	local baseblackcards = [[_? There's an app for that
	Why can't I sleep at night? _
	What's that smell? _
	I got 99 problems but _ ain't one.
	Who stole the cookies from the cookie jar? _
	What's the next Happy Meal (r) toy? _
	Anthropologists have recently discovered a primitive tribe that worships _.
	It's a pity that kids these days are all getting involved with _.
	During Picasso's often-overlooked Brown Period, he produced hundreds of paintings of _.
	Alternative medicine is now embracing the curative powers of _.
	And the Academy Award for _ goes to _.
	What's that sound? _
	What ended my last relationship? _
	MTV's new reality TV show features eight washed-up celebrities living with _.
	I drink to forget _.
	I'm sorry, I couldn't complete my homework because of _.
	What is Batman's guilty pleasure? _
	This is the way the world ends \ This is the way the world ends \ Not with a bang but with _.
	What's a girl's best friend? _
	TSA guidelines now prohibit _ on airplanes.
	_. That's how I want to die.
	For my next trick, I will pull _ out of _.
	In the new Disney Channel Original Movie, Hannah Montana struggles with _ for the first time.
	_ is a slippery slope that leads to _.
	What does Dick Cheney prefer? _
	I wish I hadn't lost the instruction manual for _.
	Instead of coal, Santa now gives the bad children _.
	What's the most emo? _
	In 1,000 years, when paper money is but a distant memory, _ will be our currency.
	What's the next superhero/sidekick duo? _ _
	In M. Night Shyamalan's new movie, Bruce Willis discovers that _ had really been _ all along
	A romantic, candlelit dinner would be incomplete without _.
	_. Betcha can't have just one!
	White people like _.
	_. High five, bro.
	Next from J.K. Rowling: Harry Potter and Chamber of _.
	BILLY MAYS HERE FOR _.
	In a world ravaged by _, our only solace is _.
	War! What is it good for? _
	During sex, I like to think about _.
	What are my parents hiding from me? _
	What will always get you laid? _
	When I'm in prison, I'll have _ smuggled in.
	What did I bring back from Mexico? _
	What don't you want to find in your Chinese food? _
	What will I bring back in time to convince people that I am a powerful wizard? _
	How am I maintaining my relationship status? _
	Coming to Broadway this season, _: The Musical.
	While the United States raced the Soviet Union to the moon, the Mexican government funnelled millions of pesos into research on _.
	After Hurricane Katrina, Sean Penn brought _ to the people of New Orleans.
	Due to a PR fiasco, Walmart no longer offers _.
	In his new summer commedy, Rob Schneider is _ trapped in the body of _.
	Rumour has it that Vladimir Putin's favorite dish is _ stuffed with _.
	But before I kill you Mr. Bond, I must show you _.
	What gives me uncontrollable gas? _
	What do old people smell like? _
	The class field trip was completely ruined by _.
	When Pharaoh remained unmoved, Moses called down a Plague of _.
	What's my secret power? _
	what's there a ton of in heaven? _
	What would grandma find disturbing, yet oddly charming? _
	I never truly understood _ until I encountered _.
	The US has begun airdropping _ to the children of Afghanistan.
	What helps Obama unwind? _
	What did Vin Diesel eat for dinner? _
	_: good to the last drop.
	Why am I sticky? _
	What gets better with age? _
	_: kid-tested, mother-approved.
	What's the crustiest? _
	What's Teach for America using to inspire inner city students to succeed? _
	Studies show that lab rats navigate mazes 50% faster after being exposed to _.
	Life was difficult for cavemen before _.
	Make a haiku. _ _ _
	I do not know with what weapons World War III will be fought, but World War IV will be fought with _.
	Why do I hurt all over? _
	What am I giving up for Lent? _
	In Michael Jackson's final moments, he thought about _.
	In an attempt to reach a wider audience, the Smithsonian Museum of Natural History has opened an interactive exhibit on _.
	When I am President of the United States, I will create the department of _.
	Lifetime (r) presents _, the story of _.
	When I am a billionare, I shall erect a 50-foot statue to commemorate _.
	When I was tripping on acid, _ turned into _.
	That's right, I killed _. How, you ask? _.
	What's my anti-drug? _
	_ + _ = _.
	What never fails to liven up the party? _
	What's the new fad diet? _
	Major League Baseball has banned _ for giving players an unfair advantage.]]

	local basewhitecards = [[Coat hanger abortions
	Man meat
	Autocannibalism
	Vigorous jazz hands
	Flightless birds
	Pictures of boobs
	Doing the right thing
	Hunting accidents
	A cartoon camel enjoying the smooth, refreshing taste of a cigarette
	The violation of our most basic human rights
	Viagra (r)
	Self-loathing
	Spectacular abs
	An honest cop with nothing left to lose
	Abstinence
	A balanced breakfast
	Mountain Dew Code Red
	Concealing a boner
	Roofies
	Glenn Beck convulsively vomiting as a brood of crab spiders hatches in his brain and erupts from his tear ducts
	Tweeting
	The Big Bang
	Amputees
	Dr. Martin Luther King, Jr.
	Former President George W. Bush
	Being marginalized
	Smegma
	Laying an egg
	Cuddling
	Aaron Burr
	The Pope
	A bleached asshole
	Horse meat
	Genital piercings
	Fingering
	Elderly Japanese men
	Stranger danger
	Fear itself
	Science
	Praying the gay away
	Same-sex ice dancing
	The terrorists
	Making sex at here
	German dungeon porn
	Bingeing and purging
	Ethnic cleansing
	Cheating in the Special Olympics
	Nickelback
	Heteronormativity
	William Shatner
	Making a pouty face
	Chainsaws for hands
	The placenta
	The profoundly handicapped
	Tom Cruise
	Object permanence
	Goblins
	An icepick lobotomy
	Arnold Schwarzenegger
	Hormone injections
	A falcon with a cap on its head
	Foreskin
	Dying
	Stunt doubles
	The invisible hand
	Jew-fros
	A really cool hat
	Flash flooding
	Flavored condoms
	Dying of dysyntery
	Sexy pillow fights
	The Three-Fifths compromise
	A sad handjob
	Men
	Historically black colleges
	Sean Penn
	Heartwarming orphans
	Waterboarding
	The clitoris
	Vikings
	Friends who eat all the snacks
	The Underground Railroad
	Pretending to care
	Raptor attacks
	A micropenis
	A Gypsy curse
	Agriculture
	Bling
	A clandestine butt scratch
	The South
	Sniffing glue
	Consultants
	My humps
	Geese
	Being a dick to children
	Party poopers
	Sunshine and rainbows
	YOU MUST CONSTRUCT ADDITIONAL PYLONS
	Mutually-assured destruction
	Heath Ledger
	Sexting
	An Oedipus complex
	Eating all of the cookies before the AIDS bake-sale
	A sausage festival
	Michael Jackson
	Skeletor
	Chivalry
	Sharing needles
	Being rich
	Muzzy
	Count Chocula
	Spontaneous human combustion
	College
	Necrophilia
	The Chinese gymnastics team
	Global warming
	Farting and walking away
	Emotions
	Uppercuts
	Cookie Monster devouring the Eucharist wafers
	Stifling a giggle at the mention of Hutus and Tutsis
	Penis envy
	Letting yourself go
	White people
	Dick Cheney
	Leaving an awkward voicemail
	Yeast
	Natural selection
	Masturbation
	Twinkies (r)
	A LAN Party
	Opposable thumbs
	A grande sugar-free iced soy caramel macchiato
	Soiling oneself
	A sassy black woman
	Sperm whales
	Teaching a robot to love
	Scrubbing under the folds
	A drive-by shooting
	Whipping it out
	Panda sex
	Catapults
	Will Smith
	Toni Morrison's vagina
	Five-Dollar Foot-longs (tm)
	Land minds
	A sea of troubles
	A zesty breakfast burrito
	Christopher Walken
	Friction
	Balls
	AIDS
	The KKK
	Figgy pudding
	Seppuku
	Marky Mark and the Funky Bunch
	Gandhi
	Dave Matthews Band
	Preteens
	The token minority
	Friends with benefits
	Re-gifting
	Pixelated bukkake
	Substitute teachers
	Take-backsies
	A thermonuclear detonation
	The Tempur-Pedic (r) Swedish Sleep System (tm)
	Waiting 'til marriage
	A tiny horse
	A can of whoop-ass
	Dental dams
	Feeding Rosie O'Donnell
	Old-people smell
	Genghis Khan
	Authentic Mexican cuisine
	Oversized lollipops
	Garth Brooks
	Keanu Reeves
	Drinking alone
	The American Dream
	Taking off your shirt
	Giving 110%
	Flesh-eating bacteria
	Child abuse
	A cooler full of organs
	A moment of silence
	The Rapture
	Keeping Christ in Christmas
	RoboCop
	That one gay Teletubby
	Sweet, sweet vengeance
	Fancy Feast (r)
	Pooping back and forth. Forever.
	Being a motherfucking sorcerer
	Jewish fraternities
	Edible underpants
	Poor people
	All-you-can-eat shrimp for $4.99
	Britney Spears at 55
	That thing that electrocutes your abs
	The folly of man
	Fiery poops
	Cards Against Humanity
	A murder most foul
	Me time
	The inevitable heat death of the universe
	Nocturnal emissions
	Daddy issues
	The hardworking Mexican
	Natalie Portman
	Waking up half-naked in a Denny's parking lot
	Nipple blades
	Assless chaps
	Full frontal nudity
	Hulk Hogan
	Passive-aggression
	Ronald Reagan
	Vehicular manslaughter
	Menstruation
	Pulling out
	Picking up girls at the abortion clinc
	The homosexual agenda
	The Holy Bible
	World peace
	Dropping a chandelier on your enemies and riding the rope up
	Testicular torsion
	The milk man
	A time-travel paradox
	Hot Pockets (r)
	Guys who don't call
	Eating the last known bison
	Darth Vader
	Scalping
	Homeless people
	The World of Warcraft
	Gloryholes
	Saxophone solos
	Sean Connery
	God
	Intelligent design
	The taint; the grundle; the fleshy fun-bridge
	Friendly fire
	Keg stands
	Eugenics
	A good sniff
	Lockjaw
	A neglected Tamagotchi (tm)
	The People's Elbow
	Robert Downey, Jr.
	The heart of a child
	Seduction
	Smallpox blankets
	Licking things to claim them as your own
	A salty surprise
	Poorly-timed Holocaust jokes
	My soul
	My sex life
	Pterodactyl eggs
	Altar boys
	Forgetting the Alamo
	72 virgins
	Raping and pillaging
	Pedophiles
	Eastern European Turbo-folk music
	A snapping turtle biting the tip of your penis
	Pabst Blue Ribbon
	Domino's (tm) Oreo (tm) Dessert Pizza
	My collection of high-tech sex toys
	A middle-aged man on roller skates
	The Blood of Christ
	Half-assed foreplay
	Free samples
	Douchebags on their iPhones
	Hurricane Katrina
	Wearing underwear inside-out to avoid doing laundry
	Republicans
	The glass ceiling
	A foul mouth
	Jerking off into a pool of children's tears
	Getting really high
	The deformed
	Michelle Obama's arms
	Explosions
	The Übermensch
	Donald Trump
	Sarah Palin
	Attitude
	This answer is postmodern
	Crumpets with the Queen
	Frolicking
	Team-building exercises
	Repression
	Road head
	A bag of magic beans
	An asymmetric boob job
	Dead parents
	Public ridicule
	A mating display
	A mime having a stroke
	Stephen Hawking talking dirty
	African children
	Mouth herpes
	Overcompensation
	Bill Nye the Science Guy
	Bitches
	Italians
	Have some more kugel
	A windmill full of corpses
	Her Royal Highness, Queen Elizabeth II
	Crippling debt
	Adderall (tm)
	A stray pube
	Shorties and blunts
	Passing a kidney stone
	Prancing
	Leprosy
	A brain tumor
	Bees?
	Puppies!
	Cockfights
	Kim Jong-Il
	Hope
	8 oz. of sweet Mexican black-tar heroin
	Incest
	Grave robbing
	Asians who aren't good at math
	Alcoholism
	(I am doing Kegels right now.)
	Justin Bieber
	The Jews
	Bestiality
	Winking at old people
	Drum circles
	Kids with ass cancer
	Loose lips
	Auschwitz
	Civilian casualties
	Inappropriate yodeling
	Tangled Slinkys
	Being on fire
	The Thong Song
	A vajazzled vagina
	Riding off into the sunset
	Exchanging pleasantries
	My relationship status
	Shaquille O'Neals's acting career
	Being fabulous
	Lactation
	Not reciprocating oral sex
	Sobbing into a Hungry-Man (r) Frozen Dinner
	My genitals
	Date rape
	Ring Pops (tm)
	GoGurt
	Judge Judy
	Lumberjack fantasies
	The gays
	Scientology
	Estrogen
	Police brutality
	Passable transvestites
	The Virginia Tech Massacre
	Tiger Woods
	Dick fingers
	Racism
	Glenn Beck being harried by a swarm of buzzards
	Surprise sex!
	Classist undertones
	Booby-trapping the house to foil burglars
	New Age music
	PCP
	A lifetime of sadness
	Doin' it in the butt
	Swooping
	The Hamburglar
	Tentacle porn
	A hot mess
	Too much hair gel
	A look-see
	Not giving a shit about the Third World
	American Gladiators
	The Kool-Aid man
	Mr Snuffleupagus
	Barack Obama
	Golden showers
	Wiping her butt
	Queefing
	Getting drunk on mouthwash
	An M. Night Shyamalan plot twist
	A robust mongoloid
	Nazis
	White privilege
	An erection that lasts longer than four hours
	A disappointing birthday party
	Puberty
	Two midgets shitting in a bucket
	Wifely duties
	The forbidden fruit
	Getting so angry that you pop a boner
	Sexual tension
	Third base
	A gassy antelope
	Those times when you get sand in your vagina
	A Super Soaker (tm) full of cat pee
	Muhammad (Praise Be Unto Him)
	Racially-biased SAT questions
	Porn stars
	A fetus
	Obesity
	When you fart and a little bit comes out
	Oompa-Loompas
	BATMAN!!!
	Black people
	Tasteful sideboob
	Hot people
	Grandma
	Copping a feel
	The Trail of Tears
	Famine
	Finger painting
	The miracle of childbirth
	Goats eating cans
	A monkey smoking a cigar
	Faith healing
	Parting the Red Sea
	Dead babies
	The Amish
	Impotence
	Child beauty pageants
	Centaurs
	AXE Body Spray
	Kanye West
	Women's suffrage
	Children on leashes
	Harry Potter erotica
	The Dance of the Sugar Plum Fairy
	Lance Armstrong's missing testicle
	Dwarf tossing
	Mathletes
	Lunchables (tm)
	Women in yogurt commercials
	John Wilkes Booth
	Powerful thighs
	Mr. Clean, right behind you
	Multiple stab wounds
	Cybernetic enhancements
	Serfdom
	Another god-damn vampire movie
	Glenn Beck catching his scrotum on a curtain hook
	A big hoopla about nothing
	Peeing a little bit
	The Hustle
	Ghosts
	Bananas in Pajamas
	Active listening
	Dry heaving
	Kamikaze pilots
	The Force
	Anal beads
	The Make-A-Wish (r) Foundation]]

	local peniscorpblackcards = [[_ goes well with _.
	_ will penish you immediately.
	_ having gay sex with _.
	Vinh'll fix _.
	Quick, stop _.
	_ , cap.]]

	local peniscorpwhitecards = [[Vinh's bloody cunt
	Gran PC
	Jesus
	Book of Forbidden Gay Penis Sex
	Alessio's pizza
	Sir Rawr's Autism
	Max of std
	Timmy's ass-truck
	Explosive Silo
	The Cock
	Skooch's shitty hacks
	The Gay Police
	Buttsecks
	Gran PC raping Overv's ragdoll with an automated drilldo
	Gran PC and Eli's tr_idle
	Gayry Newfag
	WhY's blank stare]]

	function CAH:AddCardsFromString( str , cardtype , expansion )
		if not str then return end
		
		local cardtable = cardtype == CAH.WHITE_CARD and CAH.WHITE_CARDS or CAH.BLACK_CARDS
		
		local tab = string.Split( str , "\n" )
		for i , v in pairs( tab ) do
			if #v <= 3 then continue end
			
			local pickn = nil
			
			if cardtype == CAH.BLACK_CARD then
				pickn = 0
				for _ , _ in string.gfind( v , "_" ) do
					pickn = pickn + 1
				end
			end
			
			local t = {
				text = v,
				expansion = expansion,
				pickn = pickn,
			}
			table.insert( cardtable, t )
		end
		
	end

	CAH:AddCardsFromString( baseblackcards , CAH.BLACK_CARD , "BASE" )
	CAH:AddCardsFromString( basewhitecards , CAH.WHITE_CARD , "BASE" )
	CAH:AddCardsFromString( peniscorpblackcards , CAH.BLACK_CARD , "PNS" )
	CAH:AddCardsFromString( peniscorpwhitecards , CAH.WHITE_CARD , "PNS" )
end

--[[
	Data shit
	
	Networked shit
	
		White cards left
		Black cards left
		
		Current black card
		
		Current cah_player entities
		
		Current czar cah_player entity
	
	Non networked shit
		
		Indexes of the cards used so far
]]

local ENT = {}

ENT.Base = "sent_anim"

function ENT:Initialize()
	if SERVER then
		self.ActiveCards = {}	--table of entities
	else
	
	end
end

function ENT:Think()

end

function ENT:GetRandomCardFromDeck( cardtype , expansion )
	local deck = nil
	if cardtype == CAH.BLACK_CARD then
		deck = CAH.BLACK_CARD
	elseif cardtype == CAH.WHITE_CARD then
		deck = CAH.WHITE_CARD
	end

	if deck then
		--rudimentary random that also goes trough all the cards regardless of the deck type
		return math.random( 1 , #deck )
	end
	
	return 1
end

function ENT:OnRemove()
	--destroy all the cards, destroy all the owners and fuck up everything, game's over
	for i ,v in pairs( self.ActiveCards ) do
		if IsValid( v ) and v:GetClass() == "cah_card" then
			v:Remove()
		end
	end
end

function ENT:CreateNewCard( cardtype , expansion , owner )
	local id = self:GetRandomCardFromDeck( cardtype , expansion or "BASE" )
	if id then
		local card = ents.Create( "cah_card" )
		card:SetCardType( cardtype )
		card:SetCardIndex( id )	--this will trigger the OnCardIndexChanged callback serverside to set the text
		card:SetCardOwner( owner )
		card:SetAngles( self:GetAngles() )
		card:SetPos( self:GetCardSpawnPos() )
		card:Spawn()
	end
end

function ENT:GetCardSpawnPos()
	return self:GetPos() + self:GetUp() * 100
end

scripted_ents.Register(ENT,"cah_controller",true)

--CAH card entity
--[[
	Networked
		"player" Owner	- Entity
		Card index - Int
		Card type ( black or white ) 	- Int
]]


local ENT = {}

ENT.Base = "sent_anim"

ENT.MinBounds = Vector( 0 , 0 , 0 )
ENT.MaxBounds = Vector( 0 , 0 , 0 )

if CLIENT then
	ENT.GUIConfig = {
		Scale = 1,
		FontSize = 16,	--this will be scaled depending on the size of the panel
		Width = 300,	
		Height = 600,	
		
	}
	
	--now create the font
	surface.CreateFont( "CAH_Font"..CurTime() ,
	{
		font		= "Roboto",
		size		= ScreenScale( 10 ),
		antialias	= true,
		weight		= 300,
	})
end

function ENT:Initialize()
	if SERVER then
		
	else
		self:CreateCardPanel()
	end
end

if CLIENT then
	function ENT:CreateCardPanel()
		
	end
	
	function ENT:UpdateCardPanel()
	
	end
	
	function ENT:DrawCardPanel()
	
	end
	
	function ENT:RemoveCardPanel()
	
	end
	
	ENT.BlackCardColor = color_black
	ENT.WhiteCardColor = color_white
	
	local wireframe = Material("models/wireframe")
	
	function ENT:Draw()
		
		render.SetMaterial(wireframe)
		render.DrawBox( self:GetPos(), self:GetAngles(), self.MinBounds, self.MaxBounds, color_white, true )
		
	end

end

function ENT:SetupDataTables()
	self:NetworkVar( "Ent" , 0 , "CardOwner" )
	self:NetworkVar( "Int" , 0 , "CardIndex" )
	self:NetworkVar( "Int" , 1 , "CardType" )
	self:NetworkVar( "Int" , 2 , "CardPickCount" )
	
	
	self:NetworkVar( "String" , 0 , "InternalCardText" )
	self:NetworkVar( "String" , 1 , "CardExpansion" )
	
	
	self:NetworkVarNotify( "CardIndex", self.OnCardIndexChanged )
end

function ENT:OnCardIndexChanged( valname , oldval , newval )
	local cardinfo = self:GetCardInfo()
	if cardinfo then
		self:SetInternalCardText( cardinfo.text )
		self:SetCardExpansion( cardinfo.expansion )
		self:SetCardPickCount( cardinfo.pickn or 0 )
	else
		self:SetInternalCardText( "CARD NOT FOUND, ID: "..newval )
		self:SetCardExpansion( "BASE" )
		self:SetCardPickCount( 0 )
	end
end

function ENT:IsBlackCard()
	return self:GetCardType() == CAH.BLACK_CARD
end

function ENT:IsWhiteCard()
	return self:GetCardType() == CAH.WHITE_CARD
end

function ENT:ShouldMaskTo( ply )
	if not IsValid( ply ) then return false end
	
	local owner = self:GetCardOwner()
	if IsValid( owner ) and owner ~= ply then
		return true
	end
	
	return false
end

function ENT:Think()
end

if SERVER then

	function ENT:GetCardInfo()
		return self:IsWhiteCard() and CAH.WHITE_CARDS[self:GetCardIndex()] or CAH.BLACK_CARDS[self:GetCardIndex()]
	end

end

function ENT:GetCardPickN()
	if not self:IsBlackCard() then
		return 0
	end
end

function ENT:GetCardText()
	if self:ShouldMaskTo( LocalPlayer() ) then
		return "?"
	else
		return self:GetInternalCardText()
	end
end

function ENT:GetCardExpansion()
	local tb = self:GetCardInfo()
	if tb then
		return tb.expansion
	end
	
	return "BASE"
end


scripted_ents.Register(ENT,"cah_card",true)


--CAH "player", it's the entity holding the cards, anyone can use this "player" to interact with the cards
--this "player" allows the controlling player to mouse over cards and move them around
--also

local ENT = {}

ENT.Base = "sent_anim"

function ENT:Initialize()

end

function ENT:SetupDataTables()
	self:NetworkVar( "Ent" , 0 , "ControllingPlayer" )
	self:NetworkVar( "String" , 0 , "PlayerName" )	--set to the last player's name, or can be used to fuck around with
	
	self:NetworkVar( "Int" , 0 , "Score" )
	self:NetworkVar( "Bool" , 0 , "Czaar" )
	self:NetworkVar( "Ent" , 1 , "HoldingCard" )
	
end

function ENT:Think()
	if SERVER then
		self:HandleCardsInteraction()
	end
	
	self:NextThink( CurTime() + 0.1 )
	return true
end

function ENT:HandleCardsInteraction()
	
end
scripted_ents.Register(ENT,"cah_player",true)