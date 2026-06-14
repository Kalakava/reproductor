import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

class AppLocalizations {
  final String locale;

  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    // general
    'general.app_name': {
      'es': 'Onda',
      'en': 'Onda',
      'fr': 'Onda',
      'en_GB': 'Onda',
      'it': 'Onda',
      'pt': 'Onda',
      'zh_Hans': 'Onda'
    },
    'general.songs': {
      'es': 'Canciones',
      'en': 'Songs',
      'fr': 'Titres',
      'en_GB': 'Songs',
      'it': 'Brani',
      'pt': 'Músicas',
      'zh_Hans': '歌曲'
    },
    'general.playlists': {
      'es': 'Listas',
      'en': 'Playlists',
      'fr': 'Playlists',
      'en_GB': 'Playlists',
      'it': 'Playlist',
      'pt': 'Playlists',
      'zh_Hans': '歌单'
    },
    'general.settings': {
      'es': 'Ajustes',
      'en': 'Settings',
      'fr': 'Paramètres',
      'en_GB': 'Settings',
      'it': 'Impostazioni',
      'pt': 'Configurações',
      'zh_Hans': '设置'
    },
    'general.cancel': {
      'es': 'Cancelar',
      'en': 'Cancel',
      'fr': 'Annuler',
      'en_GB': 'Cancel',
      'it': 'Annulla',
      'pt': 'Cancelar',
      'zh_Hans': '取消'
    },
    'general.accept': {
      'es': 'Aceptar',
      'en': 'Accept',
      'fr': 'Accepter',
      'en_GB': 'Accept',
      'it': 'Accetta',
      'pt': 'Aceitar',
      'zh_Hans': '确定'
    },
    'general.delete': {
      'es': 'Eliminar',
      'en': 'Delete',
      'fr': 'Supprimer',
      'en_GB': 'Delete',
      'it': 'Elimina',
      'pt': 'Excluir',
      'zh_Hans': '删除'
    },
    'general.share': {
      'es': 'Compartir',
      'en': 'Share',
      'fr': 'Partager',
      'en_GB': 'Share',
      'it': 'Condividi',
      'pt': 'Compartilhar',
      'zh_Hans': '分享'
    },
    'general.unknown_artist': {
      'es': 'Desconocido',
      'en': 'Unknown',
      'fr': 'Inconnu',
      'en_GB': 'Unknown',
      'it': 'Sconosciuto',
      'pt': 'Desconhecido',
      'zh_Hans': '未知'
    },
    // songs_screen
    'songs_screen.title': {
      'es': 'Biblioteca de Música',
      'en': 'Music Library',
      'fr': 'Bibliothèque musicale',
      'en_GB': 'Music Library',
      'it': 'Libreria musicale',
      'pt': 'Biblioteca de Música',
      'zh_Hans': '音乐库'
    },
    'songs_screen.search_hint': {
      'es': 'Buscar canciones...',
      'en': 'Search songs...',
      'fr': 'Rechercher des titres...',
      'en_GB': 'Search songs...',
      'it': 'Cerca brani...',
      'pt': 'Buscar músicas...',
      'zh_Hans': '搜索歌曲...'
    },
    'songs_screen.no_songs': {
      'es': 'No se encontraron canciones',
      'en': 'No songs found',
      'fr': 'Aucun titre trouvé',
      'en_GB': 'No songs found',
      'it': 'Nessun brano trovato',
      'pt': 'Nenhuma música encontrada',
      'zh_Hans': '未找到歌曲'
    },
    'songs_screen.permission_denied': {
      'es': 'Permiso denegado',
      'en': 'Permission denied',
      'fr': 'Autorisation refusée',
      'en_GB': 'Permission denied',
      'it': 'Autorizzazione negata',
      'pt': 'Permissão negada',
      'zh_Hans': '权限被拒绝'
    },
    'songs_screen.retry': {
      'es': 'Reintentar',
      'en': 'Retry',
      'fr': 'Réessayer',
      'en_GB': 'Retry',
      'it': 'Riprova',
      'pt': 'Tentar novamente',
      'zh_Hans': '重试'
    },
    // playlists_screen
    'playlists_screen.title': {
      'es': 'Listas de Reproducción',
      'en': 'Playlists',
      'fr': 'Playlists',
      'en_GB': 'Playlists',
      'it': 'Playlist',
      'pt': 'Playlists',
      'zh_Hans': '歌单'
    },
    'playlists_screen.new_playlist': {
      'es': 'Nueva lista',
      'en': 'New Playlist',
      'fr': 'Nouvelle playlist',
      'en_GB': 'New Playlist',
      'it': 'Nuova playlist',
      'pt': 'Nova playlist',
      'zh_Hans': '新建歌单'
    },
    'playlists_screen.playlist_name_hint': {
      'es': 'Nombre de la lista',
      'en': 'Playlist Name',
      'fr': 'Nom de la playlist',
      'en_GB': 'Playlist Name',
      'it': 'Nome della playlist',
      'pt': 'Nome da playlist',
      'zh_Hans': '歌单名称'
    },
    'playlists_screen.create': {
      'es': 'Crear',
      'en': 'Create',
      'fr': 'Créer',
      'en_GB': 'Create',
      'it': 'Crea',
      'pt': 'Criar',
      'zh_Hans': '创建'
    },
    'playlists_screen.create_empty': {
      'es': 'Crear lista vacía',
      'en': 'Create empty playlist',
      'fr': 'Créer une playlist vide',
      'en_GB': 'Create empty playlist',
      'it': 'Crea playlist vuota',
      'pt': 'Criar playlist vazia',
      'zh_Hans': '创建空白歌单'
    },
    'playlists_screen.create_from_folder': {
      'es': 'Crear desde carpeta',
      'en': 'Create from folder',
      'fr': 'Créer à partir d'+"'"+'un dossier',
      'en_GB': 'Create from folder',
      'it': 'Crea da cartella',
      'pt': 'Criar a partir de uma pasta',
      'zh_Hans': '从文件夹创建'
    },
    'playlists_screen.select_folder': {
      'es': 'Selecciona una carpeta',
      'en': 'Select a folder',
      'fr': 'Sélectionner un dossier',
      'en_GB': 'Select a folder',
      'it': 'Seleziona una cartella',
      'pt': 'Selecionar uma pasta',
      'zh_Hans': '选择文件夹'
    },
    'playlists_screen.no_folders': {
      'es': 'No se encontraron carpetas con música',
      'en': 'No folders with music found',
      'fr': 'Aucun dossier contenant de la musique trouvé',
      'en_GB': 'No folders with music found',
      'it': 'Nessuna cartella con musica trovata',
      'pt': 'Nenhuma pasta com músicas encontrada',
      'zh_Hans': '未找到包含音乐的文件夹'
    },
    'playlists_screen.created_success': {
      'es': 'Lista creada con éxito',
      'en': 'Playlist created successfully',
      'fr': 'Playlist créée avec succès',
      'en_GB': 'Playlist created successfully',
      'it': 'Playlist creata con successo',
      'pt': 'Playlist criada com sucesso',
      'zh_Hans': '歌单创建成功'
    },
    'playlists_screen.delete_title': {
      'es': 'Eliminar lista',
      'en': 'Delete Playlist',
      'fr': 'Supprimer la playlist',
      'en_GB': 'Delete Playlist',
      'it': 'Elimina playlist',
      'pt': 'Excluir playlist',
      'zh_Hans': '删除歌单'
    },
    'playlists_screen.delete_confirm': {
      'es': '¿Estás seguro de que quieres eliminar esta lista?',
      'en': 'Are you sure you want to delete this playlist?',
      'fr': 'Voulez-vous vraiment supprimer cette playlist ?',
      'en_GB': 'Are you sure you want to delete this playlist?',
      'it': 'Sei sicuro di voler eliminare questa playlist?',
      'pt': 'Tem certeza de que deseja excluir esta playlist?',
      'zh_Hans': '确定要删除此歌单吗？'
    },
    // playlist_detail_screen
    'playlist_detail_screen.add_songs': {
      'es': 'Añadir canciones',
      'en': 'Add Songs',
      'fr': 'Ajouter des titres',
      'en_GB': 'Add Songs',
      'it': 'Aggiungi brani',
      'pt': 'Adicionar músicas',
      'zh_Hans': '添加歌曲'
    },
    'playlist_detail_screen.remove_from_playlist': {
      'es': 'Eliminar de la lista',
      'en': 'Remove from playlist',
      'fr': 'Retirer de la playlist',
      'en_GB': 'Remove from playlist',
      'it': 'Rimuovi dalla playlist',
      'pt': 'Remover da playlist',
      'zh_Hans': '从歌单中移除'
    },
    'playlist_detail_screen.play': {
      'es': 'Reproducir',
      'en': 'Play',
      'fr': 'Lire',
      'en_GB': 'Play',
      'it': 'Riproduci',
      'pt': 'Reproduzir',
      'zh_Hans': '播放'
    },
    'playlist_detail_screen.empty_playlist': {
      'es': 'Lista vacía',
      'en': 'Empty Playlist',
      'fr': 'Playlist vide',
      'en_GB': 'Empty Playlist',
      'it': 'Playlist vuota',
      'pt': 'Playlist vazia',
      'zh_Hans': '空歌单'
    },
    'playlist_detail_screen.add_to_playlist': {
      'es': 'Añadir a lista',
      'en': 'Add to playlist',
      'fr': 'Ajouter à la playlist',
      'en_GB': 'Add to playlist',
      'it': 'Aggiungi alla playlist',
      'pt': 'Adicionar à playlist',
      'zh_Hans': '添加到歌单'
    },
    // now_playing_screen
    'now_playing_screen.title': {
      'es': 'Reproduciendo',
      'en': 'Now Playing',
      'fr': 'En cours de lecture',
      'en_GB': 'Now Playing',
      'it': 'In riproduzione',
      'pt': 'Reproduzindo agora',
      'zh_Hans': '正在播放'
    },
    'now_playing_screen.next_song': {
      'es': 'Siguiente canción',
      'en': 'Next Song',
      'fr': 'Titre suivant',
      'en_GB': 'Next Song',
      'it': 'Brano successivo',
      'pt': 'Próxima música',
      'zh_Hans': '下一首'
    },
    'now_playing_screen.sleep_timer': {
      'es': 'Temporizador de Apagado',
      'en': 'Sleep Timer',
      'fr': 'Minuteur de mise en veille',
      'en_GB': 'Sleep Timer',
      'it': 'Timer di spegnimento',
      'pt': 'Temporizador',
      'zh_Hans': '睡眠定时器'
    },
    'now_playing_screen.play_queue': {
      'es': 'Cola de reproducción',
      'en': 'Play Queue',
      'fr': 'File d'+"'"+'attente',
      'en_GB': 'Play Queue',
      'it': 'Coda di riproduzione',
      'pt': 'Fila de reprodução',
      'zh_Hans': '播放队列'
    },
    'now_playing_screen.details': {
      'es': 'Detalles',
      'en': 'Details',
      'fr': 'Détails',
      'en_GB': 'Details',
      'it': 'Dettagli',
      'pt': 'Detalhes',
      'zh_Hans': '详情'
    },
    'now_playing_screen.song_details_title': {
      'es': 'Detalle del Tema',
      'en': 'Song Details',
      'fr': 'Détails du titre',
      'en_GB': 'Track Details',
      'it': 'Dettagli del brano',
      'pt': 'Detalhes da música',
      'zh_Hans': '歌曲详情'
    },
    'now_playing_screen.details_title': {
      'es': 'Título',
      'en': 'Title',
      'fr': 'Titre',
      'en_GB': 'Title',
      'it': 'Titolo',
      'pt': 'Título',
      'zh_Hans': '标题'
    },
    'now_playing_screen.details_artist': {
      'es': 'Artista',
      'en': 'Artist',
      'fr': 'Artiste',
      'en_GB': 'Artist',
      'it': 'Artista',
      'pt': 'Artista',
      'zh_Hans': '艺术家'
    },
    'now_playing_screen.details_album': {
      'es': 'Álbum',
      'en': 'Album',
      'fr': 'Album',
      'en_GB': 'Album',
      'it': 'Album',
      'pt': 'Álbum',
      'zh_Hans': '专辑'
    },
    'now_playing_screen.details_path': {
      'es': 'Ruta de archivo',
      'en': 'File Path',
      'fr': 'Emplacement du fichier',
      'en_GB': 'File Path',
      'it': 'Percorso file',
      'pt': 'Caminho do arquivo',
      'zh_Hans': '文件路径'
    },
    'now_playing_screen.details_size': {
      'es': 'Tamaño',
      'en': 'Size',
      'fr': 'Taille',
      'en_GB': 'Size',
      'it': 'Dimensioni',
      'pt': 'Tamanho',
      'zh_Hans': '大小'
    },
    'now_playing_screen.details_duration': {
      'es': 'Duración',
      'en': 'Duration',
      'fr': 'Durée',
      'en_GB': 'Duration',
      'it': 'Durata',
      'pt': 'Duração',
      'zh_Hans': '时长'
    },
    // settings_screen
    'settings_screen.customization_title': {
      'es': 'Personalización de Interfaz',
      'en': 'Interface Customization',
      'fr': "Personnalisation de l'interface",
      'en_GB': 'Interface Customisation',
      'it': 'Personalizzazione interfaccia',
      'pt': 'Personalização da interface',
      'zh_Hans': '界面个性化'
    },
    'settings_screen.typography': {
      'es': 'Tipografía:',
      'en': 'Typography:',
      'fr': 'Typographie :',
      'en_GB': 'Typography:',
      'it': 'Tipografia:',
      'pt': 'Tipografia:',
      'zh_Hans': '字体:'
    },
    'settings_screen.primary_color': {
      'es': 'Color Principal:',
      'en': 'Primary Color:',
      'fr': 'Couleur principale :',
      'en_GB': 'Primary Colour:',
      'it': 'Colore principale:',
      'pt': 'Cor principal:',
      'zh_Hans': '主题色:'
    },
    'settings_screen.background_image': {
      'es': 'Imagen de Fondo:',
      'en': 'Background Image:',
      'fr': "Image d'arrière-plan :",
      'en_GB': 'Background Image:',
      'it': 'Immagine di sfondo:',
      'pt': 'Imagem de fundo:',
      'zh_Hans': '背景图片:'
    },
    'settings_screen.background_default': {
      'es': 'Usando fondo por defecto',
      'en': 'Using default background',
      'fr': 'Arrière-plan par défaut utilisé',
      'en_GB': 'Using default background',
      'it': 'Sfondo predefinito in uso',
      'pt': 'Usando fundo padrão',
      'zh_Hans': '正在使用默认背景'
    },
    'settings_screen.background_active': {
      'es': 'Imagen personalizada activa',
      'en': 'Custom image active',
      'fr': 'Image personnalisée active',
      'en_GB': 'Custom image active',
      'it': 'Immagine personalizzata attiva',
      'pt': 'Imagem personalizada activa',
      'zh_Hans': '已启用自定义图片'
    },
    'settings_screen.choose': {
      'es': 'Elegir',
      'en': 'Choose',
      'fr': 'Choisir',
      'en_GB': 'Choose',
      'it': 'Scegli',
      'pt': 'Escolher',
      'zh_Hans': '选择'
    },
    'settings_screen.sleep_timer_title': {
      'es': 'Temporizador de Apagado',
      'en': 'Sleep Timer',
      'fr': 'Minuteur de mise en veille',
      'en_GB': 'Sleep Timer',
      'it': 'Timer di spegnimento',
      'pt': 'Temporizador',
      'zh_Hans': '睡眠定时器'
    },
    'settings_screen.sleep_timer_active': {
      'es': 'Apagando en:',
      'en': 'Turning off in:',
      'fr': 'Arrêt dans :',
      'en_GB': 'Turning off in:',
      'it': 'Spegnimento tra:',
      'pt': 'Desligando em:',
      'zh_Hans': '关闭倒计时:'
    },
    'settings_screen.sleep_timer_inactive': {
      'es': 'Temporizador inactivo',
      'en': 'Sleep timer inactive',
      'fr': 'Minuteur inactif',
      'en_GB': 'Sleep timer inactive',
      'it': 'Timer disattivato',
      'pt': 'Temporizador inativo',
      'zh_Hans': '定时器未激活'
    },
    'settings_screen.sleep_timer_sub': {
      'es': 'Pausa la música al finalizar el tiempo',
      'en': 'Pauses the music when time expires',
      'fr': 'Met la musique en pause à la fin du délai',
      'en_GB': 'Pauses the music when time expires',
      'it': 'Mette in pausa la musica allo scadere del tempo',
      'pt': 'Pausa a música quando o tempo acabar',
      'zh_Hans': '倒计时结束后暂停播放'
    },
    'settings_screen.developed_by': {
      'es': 'Desarrollado por Damián Arenas',
      'en': 'Developed by Damián Arenas',
      'fr': 'Développé par Damián Arenas',
      'en_GB': 'Developed by Damián Arenas',
      'it': 'Sviluppato da Damián Arenas',
      'pt': 'Desenvolvido por Damián Arenas',
      'zh_Hans': '由 Damián Arenas 开发'
    },
    'settings_screen.gdpr_title': {
      'es': 'Cumplimiento RGPD & Privacidad',
      'en': 'GDPR Compliance & Privacy',
      'fr': 'Conformité RGPD et confidentialité',
      'en_GB': 'GDPR Compliance & Privacy',
      'it': 'Conformità GDPR e privacy',
      'pt': 'Conformidade com o RGPD e Privacidade',
      'zh_Hans': 'GDPR 合规与隐私'
    },
    'settings_screen.gdpr_summary': {
      'es': 'Onda es un reproductor de música local privado y seguro. No recopilamos, almacenamos ni compartimos ningún dato de usuario.',
      'en': 'Onda is a private and secure local music player. We do not collect, store or share any user data.',
      'fr': 'Onda est un lecteur de musique locale privé et sécurisé. Nous ne collectons, ne stockons ni ne partageons aucune donnée utilisateur.',
      'en_GB': 'Onda is a private and secure local music player. We do not collect, store, or share any user data.',
      'it': 'Onda è un lettore di musica locale privato e sicuro. Non raccogliamo, memorizziamo o condividiamo alcun dato dell'+"'"+'utente.',
      'pt': 'Onda é um reprodutor de música local privado e seguro. Não coletamos, armazenamos ou compartilhamos dados dos usuários.',
      'zh_Hans': 'Onda 是一款私密且安全的本地音乐播放器。我们不收集、存储或共享任何用户数据。'
    },
    'settings_screen.gdpr_total_privacy_title': {
      'es': 'Privacidad Total',
      'en': 'Total Privacy',
      'fr': 'Confidentialité totale',
      'en_GB': 'Total Privacy',
      'it': 'Privacy totale',
      'pt': 'Privacidade Total',
      'zh_Hans': '绝对隐私'
    },
    'settings_screen.gdpr_total_privacy_desc': {
      'es': 'La aplicación no recopila ninguna información personal, datos de uso, telemetría o analíticas.',
      'en': 'The application does not collect any personal information, usage data, telemetry or analytics.',
      'fr': "L'application ne collecte aucune information personnelle, donnée d'utilisation, télémétrie ou analyse.",
      'en_GB': 'The application does not collect any personal information, usage data, telemetry, or analytics.',
      'it': 'L'+"'"+'applicazione non raccoglie informazioni personali, dati di utilizzo, telemetria o analisi.',
      'pt': 'O aplicativo não coleta informações pessoais, dados de uso, telemetria ou análises.',
      'zh_Hans': '本应用不收集 any 个人信息、使用数据、遥测或分析数据。'
    },
    'settings_screen.gdpr_local_data_title': {
      'es': 'Datos Locales',
      'en': 'Local Data',
      'fr': 'Données locales',
      'en_GB': 'Local Data',
      'it': 'Dati locali',
      'pt': 'Dados Locais',
      'zh_Hans': '本地数据'
    },
    'settings_screen.gdpr_local_data_desc': {
      'es': 'El acceso al almacenamiento del dispositivo se utiliza exclusivamente para indexar y reproducir tus archivos locales de música. Ningún dato sale de tu dispositivo.',
      'en': 'Device storage access is used exclusively to index and play your local music files. No data leaves your device.',
      'fr': "L'accès au stockage de l'appareil est utilisé exclusivement pour indexer et lire vos fichiers musicaux locaux. Aucune donnée ne quitte votre appareil.",
      'en_GB': 'Device storage access is used exclusively to index and play your local music files. No data leaves your device.',
      'it': 'L'+"'"+'accesso all'+"'"+'archiviazione del dispositivo è utilizzato esclusivamente per indicizzare e riprodurre i tuoi file musicali locali. Nessun dato lascia il tuo dispositivo.',
      'pt': 'O acesso ao armazenamento do dispositivo é usado exclusivamente para indexar e reproduzir seus arquivos de música locais. Nenhum dado sai do seu dispositivo.',
      'zh_Hans': '访问设备存储权限仅用于索引和播放您的本地音乐 file。任何数据都不会离开您的设备。'
    },
    'settings_screen.gdpr_responsible_title': {
      'es': 'Responsable',
      'en': 'Data Controller',
      'fr': 'Responsable du traitement',
      'en_GB': 'Data Controller',
      'it': 'Titolare del trattamento',
      'pt': 'Controlador de Dados',
      'zh_Hans': '数据控制者'
    },
    'settings_screen.gdpr_responsible_desc': {
      'es': 'Damián Arenas, como desarrollador de Onda, es el responsable único del tratamiento (estrictamente local) de acuerdo con el RGPD.',
      'en': 'Damián Arenas, as developer of Onda, is the sole controller of the local processing under GDPR.',
      'fr': "Damián Arenas, en tant que développeur d'Onda, est l'unique responsable du traitement local conformément au RGPD.",
      'en_GB': 'Damián Arenas, as the developer of Onda, is the sole controller of the local processing under GDPR.',
      'it': 'Damián Arenas, come sviluppatore di Onda, è l'+"'"+'unico titolare del trattamento locale ai sensi del GDPR.',
      'pt': 'Damián Arenas, como desenvolvedor do Onda, é o único responsável pelo processamento local sob o RGPD.',
      'zh_Hans': '作为 Onda 的开发者，Damián Arenas 是 GDPR 规定下本地数据处理的唯一控制者。'
    },
    // credits_screen
    'credits_screen.title': {
      'es': 'Créditos e Información',
      'en': 'Credits & Information',
      'fr': 'Crédits et informations',
      'en_GB': 'Credits & Information',
      'it': 'Crediti e informazioni',
      'pt': 'Créditos e Informações',
      'zh_Hans': '鸣谢与信息'
    },
    'credits_screen.lead_dev': {
      'es': 'Desarrollador Principal',
      'en': 'Lead Developer',
      'fr': 'Développeur principal',
      'en_GB': 'Lead Developer',
      'it': 'Sviluppatore principale',
      'pt': 'Desenvolvedor Principal',
      'zh_Hans': '首席开发者'
    },
    'credits_screen.lead_dev_desc': {
      'es': 'Diseño y Programación',
      'en': 'Design & Programming',
      'fr': 'Conception et programmation',
      'en_GB': 'Design & Programming',
      'it': 'Progettazione e programmazione',
      'pt': 'Design e Programação',
      'zh_Hans': '设计与编程'
    },
    'credits_screen.special_thanks': {
      'es': 'Agradecimientos Especiales',
      'en': 'Special Thanks',
      'fr': 'Remerciements spéciaux',
      'en_GB': 'Special Thanks',
      'it': 'Ringraziamenti speciali',
      'pt': 'Agradecimentos Especiais',
      'zh_Hans': '特别鸣谢'
    },
    'credits_screen.community_desc': {
      'es': 'Comunidad de Flutter',
      'en': 'Flutter Community',
      'fr': 'Communauté Flutter',
      'en_GB': 'Flutter Community',
      'it': 'Comunità di Flutter',
      'pt': 'Comunidade Flutter',
      'zh_Hans': 'Flutter 社区'
    },
    'credits_screen.third_party': {
      'es': 'Bibliotecas de terceros',
      'en': 'Third-party libraries',
      'fr': 'Bibliothèques tierces',
      'en_GB': 'Third-party libraries',
      'it': 'Librerie di terze parti',
      'pt': 'Bibliotecas de terceiros',
      'zh_Hans': '第三方库'
    },
    'credits_screen.privacy_credits_title': {
      'es': 'Privacidad y Seguridad',
      'en': 'Privacy & Security',
      'fr': 'Confidentialité et sécurité',
      'en_GB': 'Privacy & Security',
      'it': 'Privacy e sicurezza',
      'pt': 'Privacidade e Segurança',
      'zh_Hans': '隐私与安全'
    },
    'credits_screen.privacy_credits_desc': {
      'es': 'Cumplimiento total con RGPD. Queda prohibida la copia, reproducción o modificación de esta app.',
      'en': 'Full compliance with GDPR. Copying, reproduction or modification of this app is prohibited.',
      'fr': 'Conformité totale au RGPD. La copie, la reproduction ou la modification de cette application est interdite.',
      'en_GB': 'Full compliance with GDPR. Copying, reproduction, or modification of this app is prohibited.',
      'it': 'Piena conformità al GDPR. È vietata la copia, riproduzione o modifica di questa app.',
      'pt': 'Total conformidade com o RGPD. É proibida a cópia, reprodução ou modificação deste aplicativo.',
      'zh_Hans': '完全符合 GDPR 标准。禁止复制、转载或修改本应用。'
    }
  };

  String translate(String key) {
    final categoryMap = _localizedValues[key];
    if (categoryMap != null) {
      final val = categoryMap[locale];
      if (val != null && val.isNotEmpty) {
        return val;
      }
      final enVal = categoryMap['en'];
      if (enVal != null && enVal.isNotEmpty) {
        return enVal;
      }
      final esVal = categoryMap['es'];
      if (esVal != null && esVal.isNotEmpty) {
        return esVal;
      }
    }
    return key;
  }
}

final l10nProvider = Provider<AppLocalizations>((ref) {
  final settings = ref.watch(settingsProvider);
  final userLang = settings.languageCode;

  String activeLang = 'es';
  if (userLang == 'system') {
    final sysLocale = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    final sysCountry = PlatformDispatcher.instance.locale.countryCode?.toLowerCase() ?? '';

    if (sysLocale == 'es') {
      activeLang = 'es';
    } else if (sysLocale == 'fr') {
      activeLang = 'fr';
    } else if (sysLocale == 'it') {
      activeLang = 'it';
    } else if (sysLocale == 'pt') {
      activeLang = 'pt';
    } else if (sysLocale == 'zh') {
      activeLang = 'zh_Hans';
    } else if (sysLocale == 'en') {
      if (sysCountry == 'gb' || sysCountry == 'uk') {
        activeLang = 'en_GB';
      } else {
        activeLang = 'en';
      }
    }
  } else {
    activeLang = userLang;
  }
  return AppLocalizations(activeLang);
});
