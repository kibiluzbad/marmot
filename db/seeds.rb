project = Project.create(name: 'Marmot',
                         language: 'ruby')
Repository.create(url: 'https://github.com/kibiluzbad/marmot.git',
                  project: project)
