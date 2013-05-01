TentAdmin.Models.App = class AppModel extends Marbles.Model
  @model_name: 'app'
  @id_mapping_scope: ['id', 'entity']

  @post_type: new TentClient.PostType('https://tent.io/types/app/v0#')
