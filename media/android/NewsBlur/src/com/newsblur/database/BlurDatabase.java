package com.newsblur.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class BlurDatabase extends SQLiteOpenHelper {

	private final String TEXT = " text";
	private final String INTEGER = " integer";
	private final static String TAG = "DatabaseHelper";
	private final static String DB_NAME = "blur.db";
	private final static int VERSION = 1;
	
	public BlurDatabase(Context context) {
		super(context, DB_NAME, null, VERSION);
		Log.d(TAG, "Initiating database");
	}
	
	private final String FOLDER_SQL = "CREATE TABLE " + DatabaseConstants.FOLDER_TABLE + " (" +
		DatabaseConstants.FOLDER_ID + TEXT + ", " +
		DatabaseConstants.FOLDER_NAME + TEXT + 
		")";
	
	private final String FEED_SQL = "CREATE TABLE " + DatabaseConstants.FEED_TABLE + " (" +
		DatabaseConstants.FEED_ID + INTEGER + ", " +
		DatabaseConstants.FEED_ACTIVE + TEXT + ", " +
		DatabaseConstants.FEED_ADDRESS + TEXT + ", " + 
		DatabaseConstants.FEED_FAVICON_COLOUR + TEXT + ", " +
		DatabaseConstants.FEED_FAVICON_FADE + TEXT + ", " + 
		DatabaseConstants.FEED_LINK + TEXT + ", " + 
		DatabaseConstants.FEED_SUBSCRIBERS + TEXT + ", " +
		DatabaseConstants.FEED_TITLE + TEXT + ", " + 
		DatabaseConstants.FEED_UPDATED_SECONDS +
		")";
	
	private final String STORY_SQL = "CREATE TABLE " + DatabaseConstants.STORY_TABLE + " (" +
		DatabaseConstants.STORY_AUTHORS + TEXT + ", " +
		DatabaseConstants.STORY_CONTENT + TEXT + ", " +
		DatabaseConstants.STORY_DATE + TEXT + ", " +
		DatabaseConstants.STORY_FEED_ID + INTEGER + ", " +
		DatabaseConstants.STORY_ID + TEXT + ", " +
		DatabaseConstants.STORY_INTELLIGENCE_AUTHORS + INTEGER + ", " +
		DatabaseConstants.STORY_INTELLIGENCE_FEED + INTEGER + ", " + 
		DatabaseConstants.STORY_INTELLIGENCE_TAGS + INTEGER + ", " +
		DatabaseConstants.STORY_INTELLIGENCE_TITLE + INTEGER + ", " +
		DatabaseConstants.STORY_PERMALINK + TEXT + ", " + 
		DatabaseConstants.STORY_READ + TEXT + ", " +
		DatabaseConstants.STORY_TITLE + TEXT + 
		")";
	
	private final String CLASSIFIER_SQL = "CREATE TABLE " + DatabaseConstants.CLASSIFIER_TABLE + " (" +
		DatabaseConstants.CLASSIFIER_ID + TEXT + ", " +
		DatabaseConstants.CLASSIFIER_KEY + TEXT + ", " + 
		DatabaseConstants.CLASSIFIER_TYPE + TEXT + ", " +
		DatabaseConstants.CLASSIFIER_VALUE + TEXT +
		")";
	
	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL(FEED_SQL);
		db.execSQL(FOLDER_SQL);
		db.execSQL(STORY_SQL);
		db.execSQL(CLASSIFIER_SQL);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int previousVersion, int nextVersion) {
		// TODO: Handle DB version updates using switch 
	}

}