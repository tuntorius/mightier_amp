package boaventura.com.devel.br.flutteraudioquery.loaders;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;
import android.util.Size;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import boaventura.com.devel.br.flutteraudioquery.loaders.tasks.AbstractLoadTask;
import io.flutter.plugin.common.MethodChannel;

public class ImageLoader extends AbstractLoader {
    public ImageLoader(Context context) {
        super(context);
    }

    public synchronized void searchArtworkBytes( final MethodChannel.Result result, final int resourceType,
                                                 final String id, final Size size  ){
        if (id == null || id.isEmpty()) {
            result.error("NO_ID", "id is required", null);
            return;
        }

        String[] args = null;
        String selection = "";
        String sortOrder = null;

        switch (resourceType){
            // artist
            case 0:
                selection = MediaStore.Audio.Media.ARTIST_ID + " = ? ";
                args = new String[] {id};
                break;

            // album
            case 1:
                selection = MediaStore.Audio.Media.ALBUM_ID + " = ? ";
                args = new String[] {id};
                break;
            // song
            case 2:
                selection = MediaStore.Audio.Media._ID + " = ? ";
                args = new String[]{id};
                break;
        }
        new ImageLoadTask(result, getContentResolver(), selection, args, sortOrder, resourceType, size ).execute();
    }

    @Override
    protected ImageLoadTask createLoadTask(MethodChannel.Result result,
                                              String selection, String[] selectionArgs, String sortOrder, int type) {
        return null;
    }

    private static class ImageLoadTask extends AbstractLoadTask< Map<String,Object> > {
        private MethodChannel.Result m_result;
        private ContentResolver m_resolver;
        private int m_queryType;
        private Size size;
        private static final String key = "image";


        /**
         *
         * @param result
         * @param m_resolver
         * @param selection
         * @param selectionArgs
         * @param sortOrder
         */
        ImageLoadTask(MethodChannel.Result result, ContentResolver m_resolver, String selection,
                     String[] selectionArgs, String sortOrder, int type, Size size){

            super(selection, selectionArgs, sortOrder);
            this.m_resolver = m_resolver;
            this.m_result = result;
            this.m_queryType = type;
            this.size = size;
        }

        @Override
        protected void onPostExecute(Map<String,Object> map)     {
            super.onPostExecute(map);
            m_result.success(map);
            this.m_resolver = null;
            this.m_result = null;
        }

        // finds an image
        private Map<String,Object> findImage(Cursor cursor) {

            Map<String, Object> map = new HashMap<>();


            if (cursor != null){
                while(cursor.moveToNext()){
                    final Uri uri = ContentUris.appendId(
                            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI.buildUpon(),
                            cursor.getLong( cursor.getColumnIndex(MediaStore.Audio.Media._ID) ))
                            .build();

                    try {
                        Bitmap bitmap = this.m_resolver.loadThumbnail(uri, this.size , null);
                        map.put(key, getBitmapBytes(bitmap) );
                        bitmap.recycle();
                        break;
                    }
                    catch (IOException ex){
                        Log.i("DBG_TEST", "A problem here " + ex.getMessage());
                    }

                }
                Log.i("DBG_TEST", " END WHILE  " );
            }

            if (map.isEmpty())
                map.put(key, null);

            if (cursor != null)
                cursor.close();
            return map;
        }

        // extract bitmap raw bytes.
        private byte[] getBitmapBytes(Bitmap bmp){
            byte[] imageBytes = null;
            try {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                bmp.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                imageBytes = baos.toByteArray();
                baos.close();
            } catch (Exception ex){
                Log.i("DBG_TEST", "Problem closing the native stream");
            }
            //String encodedImage = android.util.Base64.encodeToString(imageBytes, Base64.DEFAULT);
            return imageBytes;
        }

        @Override
        protected Map<String,Object> loadData(
                final String selection, final String [] selectionArgs,
                final String sortOrder ){

            Cursor cursor= null;

                switch (m_queryType){
                    // ARTIST OR ALBUM

                    case 0:
                    case 1:
                        cursor = this.m_resolver.query(
                                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                                new String[]{MediaStore.Audio.Media._ID}, selection, selectionArgs, sortOrder );
                        break;

                    // SONG
                    case 2:
                        Map<String, Object> map = new HashMap<>();
                        final Uri uri = ContentUris.appendId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI.buildUpon(),
                                Long.parseLong( selectionArgs[0] )).build();
                        try {
                            Bitmap bitmap = this.m_resolver.loadThumbnail(uri, size, null);
                            map.put(key, getBitmapBytes(bitmap));
                        }
                        catch (IOException ex){
                            //Log.i("DBG", "Problem reading song image " + ex.toString());
                        }

                        if (map.isEmpty())
                            map.put(key, null);

                        return map;
                }

                return findImage(cursor);
        }


    }
}
