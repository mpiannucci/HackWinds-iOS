# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

use_frameworks!

def shared_deps
    pod 'GoogleAPIClientForREST'
end


target 'HackWindsDataKit' do
    platform :ios, '10.1'
    
    shared_deps

    target 'HackWinds' do
        inherit! :search_paths

        pod 'Charts'
    end

    target 'HackWindsToday' do
        inherit! :search_paths
    end
end

target 'HackWindsDataKitWatchOS' do
    platform :watchos, '3.2'
    
    shared_deps

    target 'HackWindsWatchApp Extension' do
        inherit! :search_paths
    end
end

target 'HackWindsDataKitOSX' do
    platform :osx, '10.13'

    shared_deps

    target 'HackWindsOSX' do
        inherit! :search_paths
    end

    target 'HackWindsOSXToday' do
        inherit! :search_paths
    end
end
