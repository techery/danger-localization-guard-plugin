module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure all localizationa are in place
  #
  #          my_plugin.checkModifiedLocalizations
  #
  # @see  Max Sysenko/danger-localization_guard
  # @tags localization, iOS, .strings
  #
  class DangerLocalizationGuard < Plugin

    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<Hash>]
    attr_accessor :deleted_localizations
    attr_accessor :modified_localizations
    attr_accessor :added_localizations

    def obtainResourceValues(resourceName)
      startPos = resourceName.index(';')
      if (startPos != nil)
        resourceName.slice!(0)
        resourceName.slice!(startPos - 1..-1)
        splittedElements = resourceName.split("=");
        key = splittedElements[0].strip;
        value = splittedElements[1].strip;
        return key, value
      end
      return ""
    end

    def isTranslationsFile(file)
      return (file.end_with? ".strings" and file.include? "Localizable")
    end

    def isSharedCodeResource(string)
      components = string.split(File::SEPARATOR)
      return components.any? {|x| x.eql? "SharedCode"}
    end

    def isLocalResource(string)
      components = string.split(File::SEPARATOR)
      return components.any? {|x| x.eql? "Local"}
    end

    def isSmartCardResource(string)
      components = string.split(File::SEPARATOR)
      return components.any? {|x| x.eql? "SmartCard"}
    end

    def isDreamTripsResource(string)
      components = string.split(File::SEPARATOR)
      return components.any? {|x| x.eql? "DreamTrip"}
    end

    def bold(string)
      return "**" + string + "**"
    end
    def italic(string)
      return "_" + string + "_"
    end

    def checkModifiedLocalizations()
      deletedLocalizations = []
      addedLocalizations = []
      modifiedLocalizations = []

      deletedResourceFiles = []
      addedResourceFiles = []

      allModifiedKeys = []

      git.deleted_files.each do |deletedFile|
        if isTranslationsFile(deletedFile)
          deletedResourceFiles << deletedFile
        end
      end

      git.added_files.each do |addedFile|
        if isTranslationsFile(addedFile)
          addedResourceFiles << addedFile
        end
      end

      deletedResourceFiles.each { |file|
        warn("Resource file #{file} was deleted")
      }

      markdowns = git.modified_files
      modifiedLocalizationFiles = markdowns.select{ |file| isTranslationsFile(file)}

      modifiedLocalizationFiles.each do |modifiedFile|
        git.diff_for_file(modifiedFile).patch.each_line do |line|
          key, value = nil
          if line.start_with? '-"'
            key, value = obtainResourceValues(line)
            foundAssociatedAddedKey = addedLocalizations.select { |hash| hash[:resourceKey].eql? key}[0]
            if (foundAssociatedAddedKey)
              addedLocalizations.delete(foundAssociatedAddedKey)
              modifiedLocalizations << {:resourceKey=>key, :resourceValue=>value, :oldValue=>foundAssociatedAddedKey[:resourceValue], :fileName=>modifiedFile}
            else
              deletedLocalizations << {:resourceKey=>key, :resourceValue=>value, :fileName=>modifiedFile} unless key.empty?
            end
          end
          if line.start_with? '+"'
            key, value = obtainResourceValues(line)
            foundAssociatedDeletedKey = deletedLocalizations.select { |hash| hash[:resourceKey].eql? key}[0]
            if (foundAssociatedDeletedKey)
              deletedLocalizations.delete(foundAssociatedDeletedKey)
              modifiedLocalizations << {:resourceKey=>key, :resourceValue=>value, :oldValue=>foundAssociatedDeletedKey[:resourceValue], :fileName=>modifiedFile}
            else
              addedLocalizations << {:resourceKey=>key, :resourceValue=>value, :fileName=>modifiedFile} unless key.empty?
            end
          end
          allModifiedKeys << key if key != nil
        end
      end

      allModifiedKeys.uniq.each { |key|
        deletedFromFiles = deletedLocalizations.select { |hash| hash[:resourceKey].eql? key}.map { |hash| "(-)Deleted from " + italic(hash[:fileName])}

        allChanges = deletedFromFiles

        warn("Resource " + bold("#{key}") + ": \n#{allChanges.join("\n ")}") unless allChanges.empty?
      }

      hintMessage = "New localization strings was added. Don't forget to run the following commads to upload translations to Smartling:\n";
      commandHints = []
      allNewAddedTranslations = addedResourceFiles + addedLocalizations.map { |hash| hash[:fileName] }
      allNewAddedTranslations.uniq.each { |file|
        commandHints << "`bundle exec fastlane post_translations infrastructure:SharedCode`" if isSharedCodeResource(file)
        commandHints << "`bundle exec fastlane post_translations feature:Local`" if isLocalResource(file)
        commandHints << "`bundle exec fastlane post_translations feature:SmartCard`" if isSmartCardResource(file)
        commandHints << "`bundle exec fastlane post_translations project:DreamTrip`" if isDreamTripsResource(file)
      }

      self.deleted_localizations = deletedLocalizations
      self.added_localizations = addedLocalizations
      self.modified_localizations = modifiedLocalizations

      warn("#{hintMessage}#{commandHints.uniq.join("\n")}") unless allNewAddedTranslations.empty?
    end

  end
end
